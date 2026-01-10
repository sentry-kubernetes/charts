#!/bin/bash

set -euo pipefail

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Конфигурация
HELM_VERSION="v3.14.4"
PYTHON_VERSION="3.9"
CHART_TESTING_VERSION="v3.14.0"
KIND_CLUSTER_NAME="${KIND_CLUSTER_NAME:-kind}"

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Проверка наличия необходимых команд
check_command() {
    if ! command -v "$1" &> /dev/null; then
        log_error "$1 не установлен"
        return 1
    fi
    return 0
}

# Установка Helm
install_helm() {
    if check_command helm; then
        local current_version
        current_version=$(helm version --template='{{.Version}}' | sed 's/v//')
        log_info "Helm уже установлен: $current_version"
        return 0
    fi
    
    log_info "Установка Helm $HELM_VERSION..."
    curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
    helm version
}

# Установка Python
install_python() {
    if check_command python3; then
        local python_ver
        python_ver=$(python3 --version | cut -d' ' -f2 | cut -d'.' -f1,2)
        log_info "Python уже установлен: $python_ver"
        if [[ "$python_ver" == "$PYTHON_VERSION" ]]; then
            return 0
        fi
    fi
    
    log_warn "Python $PYTHON_VERSION требуется, но может не быть установлен"
    log_info "Убедитесь, что Python $PYTHON_VERSION установлен в системе"
}

# Установка chart-testing
install_chart_testing() {
    if [[ -f "./ct" ]]; then
        log_info "chart-testing уже установлен в текущей директории"
        ./ct version
        return 0
    fi
    
    log_info "Установка chart-testing..."
    
    # Скачиваем и распаковываем ct в текущую директорию
    # Формат имени файла изменился в новых версиях
    CT_VERSION_NO_V="${CHART_TESTING_VERSION#v}"  # Убираем префикс v
    CT_TARBALL="chart-testing_${CT_VERSION_NO_V}_linux_amd64.tar.gz"
    CT_URL="https://github.com/helm/chart-testing/releases/download/${CHART_TESTING_VERSION}/${CT_TARBALL}"
    
    log_info "Скачивание chart-testing с $CT_URL..."
    curl -L -o "$CT_TARBALL" "$CT_URL"
    tar -xzf "$CT_TARBALL"
    chmod +x ./ct
    rm "$CT_TARBALL"
    
    ./ct version
}

# Установка kubectl
install_kubectl() {
    if check_command kubectl; then
        log_info "kubectl уже установлен"
        kubectl version --client
        return 0
    fi
    
    log_info "Установка kubectl..."
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    rm kubectl
    kubectl version --client
}

# Установка kind
install_kind() {
    if check_command kind; then
        log_info "kind уже установлен"
        kind version
        return 0
    fi
    
    log_info "Установка kind..."
    ARCH=$(uname -m)
    case $ARCH in
        x86_64) ARCH="amd64" ;;
        aarch64|arm64) ARCH="arm64" ;;
        *) log_error "Неподдерживаемая архитектура: $ARCH"; exit 1 ;;
    esac
    
    curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-${ARCH}
    chmod +x ./kind
    sudo mv ./kind /usr/local/bin/kind
    kind version
}

# Добавление Helm репозиториев
add_helm_repos() {
    log_info "Добавление Helm репозиториев..."
    helm repo add sentry-kubernetes https://sentry-kubernetes.github.io/charts || true
    helm repo add bitnami https://charts.bitnami.com/bitnami || true
    helm repo add altinity https://helm.altinity.com || true
    helm repo update
}

# Запуск lint для charts/sentry
run_lint() {
    log_info "Запуск helm lint для charts/sentry..."
    helm lint charts/sentry
}

# Создание kind кластера
create_kind_cluster() {
    log_info "Создание kind кластера..."
    
    # Проверяем, существует ли кластер
    if kind get clusters | grep -q "^${KIND_CLUSTER_NAME}$"; then
        log_warn "Кластер $KIND_CLUSTER_NAME уже существует"
        if [[ "${KIND_AUTO_DELETE:-false}" == "true" ]]; then
            log_info "Автоматическое удаление существующего кластера (KIND_AUTO_DELETE=true)"
            kind delete cluster --name "$KIND_CLUSTER_NAME"
        elif [ -t 0 ]; then
            # Терминал интерактивный
            read -p "Удалить существующий кластер? (y/N) " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                kind delete cluster --name "$KIND_CLUSTER_NAME"
            else
                log_info "Используем существующий кластер"
                return 0
            fi
        else
            # Неинтерактивный режим - используем существующий кластер
            log_info "Неинтерактивный режим. Используем существующий кластер"
            return 0
        fi
    fi
    
    kind create cluster --name "$KIND_CLUSTER_NAME"
    kubectl cluster-info --context "kind-${KIND_CLUSTER_NAME}"
}

# Установка Altinity ClickHouse Operator
install_clickhouse_operator() {
    log_info "Установка Altinity ClickHouse Operator..."
    
    local operator_values="charts/sentry/ci/services/clickhouse/operator.values.yaml"
    if [[ ! -f "$operator_values" ]]; then
        log_error "Файл $operator_values не найден"
        return 1
    fi
    
    # Проверяем, установлен ли оператор
    if helm list -n default | grep -q "altinity-clickhouse-operator"; then
        log_info "Altinity ClickHouse Operator уже установлен, обновляем..."
        helm upgrade altinity-clickhouse-operator altinity/altinity-clickhouse-operator \
            --version 0.25.6 \
            --namespace default \
            --values "$operator_values" \
            --wait || true
    else
        helm install altinity-clickhouse-operator altinity/altinity-clickhouse-operator \
            --version 0.25.6 \
            --namespace default \
            --values "$operator_values" \
            --wait || true
    fi
    
    log_info "Ожидание готовности Altinity ClickHouse Operator..."
    kubectl -n default wait --for=condition=ready pod -l app.kubernetes.io/name=altinity-clickhouse-operator --timeout=120s || true
}

# Развертывание External ClickHouse
deploy_external_clickhouse() {
    log_info "Развертывание External ClickHouse..."
    
    local clickhouse_manifest="charts/sentry/ci/services/clickhouse/clickhouse-external.yaml"
    if [[ ! -f "$clickhouse_manifest" ]]; then
        log_error "Файл $clickhouse_manifest не найден"
        return 1
    fi
    
    kubectl apply -f "$clickhouse_manifest"
    
    log_info "Ожидание готовности ClickHouseInstallation..."
    kubectl -n default wait --for=jsonpath='{.status.status}'=Completed --timeout=300s clickhouseinstallation/clickhouse-external || true
}

# Запуск chart-testing install для charts в текущей директории
run_install() {
    log_info "Запуск chart-testing install для charts/sentry..."
    
    # Используем --all для установки всех charts из директории charts/
    # Это устанавливает все charts: clickhouse, sentry, sentry-kubernetes
    ./ct install --chart-dirs charts --all --debug --helm-extra-args "--timeout 1000s"
}

# Очистка
cleanup() {
    if [[ "${CLEANUP_KIND_CLUSTER:-false}" == "true" ]]; then
        log_info "Удаление kind кластера..."
        kind delete cluster --name "$KIND_CLUSTER_NAME" || true
    fi
}

# Основная функция
main() {
    log_info "Запуск lint и тестирования charts/sentry..."
    
    # Проверка наличия директории с charts
    if [[ ! -d "charts/sentry" ]]; then
        log_error "Директория charts/sentry не найдена"
        exit 1
    fi
    
    # Установка инструментов
    install_helm
    install_python
    install_chart_testing
    install_kubectl
    install_kind
    
    # Добавление репозиториев
    add_helm_repos
    
    # Lint
    run_lint
    
    # Создание кластера
    create_kind_cluster
    
    # Установка операторов и зависимостей
    install_clickhouse_operator
    deploy_external_clickhouse
    
    # Установка charts
    run_install
    
    log_info "Готово!"
}

# Обработка сигналов для очистки
trap cleanup EXIT

# Запуск основной функции
main "$@"
