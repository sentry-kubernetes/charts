# Sentry helm charts

Sentry is a cross-platform crash reporting and aggregation platform.

This repository aims to support Sentry >=10 and move out from the deprecated Helm charts official repo.

Big thanks to the maintainers of the [deprecated chart](https://github.com/helm/charts/tree/master/stable/sentry). This work has been partly inspired by it.

## Sentry Admin Secret

Before installing Sentry, you must create a secret for the admin password:

1. Create the secret:

```bash
kubectl create namespace sentry
kubectl create secret generic sentry-admin-password \
  --from-literal=admin-password='YourStrongPassword123!' \
  --namespace sentry
```

2. Set in `values.yaml`:

```yaml
user:
  existingSecret: sentry-admin-password
```

## External ClickHouse Configuration

### Background

Due to changes in the Bitnami chart catalog and container image policies (see [Issue #1828](https://github.com/sentry-kubernetes/charts/issues/1828)), the bundled ClickHouse chart dependencies are considered legacy and may receive limited updates.

It is strongly recommended to use an externally managed ClickHouse deployment. This ensures you have control over updates, backups, and high availability configurations independent of the Sentry chart.

The recommended way to deploy ClickHouse on Kubernetes is using the [Altinity ClickHouse Operator](https://github.com/Altinity/clickhouse-operator).

### Prerequisites

**Create a values file for the operator** and **install Altinity ClickHouse Operator**:
```bash
cat <<'EOF' > clickhouse-operator-values.yaml
configs:
  files:
    config.yaml:
      watch:
        namespaces:
          - sentry
EOF

helm repo add clickhouse-operator https://helm.altinity.com
helm repo update
helm upgrade --install clickhouse-operator clickhouse-operator/altinity-clickhouse-operator \
  --version 0.26.0 \
  --namespace clickhouse-operator \
  --create-namespace \
  -f clickhouse-operator-values.yaml \
  --wait
```

**Note**: Do not use `--set 'configs.files.config.yaml.watch.namespaces={sentry}'` — Helm interprets dots as nested keys, which creates a separate `config` file instead of modifying `config.yaml`, causing the operator to ignore the setting.

**Verify the operator is running**:
```bash
kubectl -n clickhouse-operator get pods -l app.kubernetes.io/name=altinity-clickhouse-operator
```
Ensure the operator pod is in `Running` state before proceeding.

### MVP Deployment with ClickHouse Keeper

Below is a Minimum Viable Product (MVP) configuration for a single-node ClickHouse instance suitable for testing or small-scale deployments. For production, we recommend a high-availability setup with at least 3 Keeper nodes and 2 ClickHouse replicas.

#### 1. ClickHouse Installation Manifest

Save this as `clickhouse.yaml`. This example deploys a single-node cluster.

```bash
cat <<'EOF' > clickhouse.yaml
apiVersion: clickhouse.altinity.com/v1
kind: ClickHouseInstallation
metadata:
  name: sentry-clickhouse
  namespace: sentry # Replace with your namespace
spec:
  configuration:
    clusters:
      - name: single-node
        layout:
          shardsCount: 1
          replicasCount: 1
    users:
      default/networks/ip:
        - "0.0.0.0/0" # Required for Sentry pods to connect
  templates:
    podTemplates:
      - name: clickhouse-single-node
        spec:
          containers:
            - name: clickhouse
              image: altinity/clickhouse-server:25.3.6.10034.altinitystable
  defaults:
    templates:
      podTemplate: clickhouse-single-node
EOF
```

**Note on Network Access**: The `users/default/networks/ip` setting is crucial. By default, ClickHouse might restrict access. Setting it to `0.0.0.0/0` allows the Sentry pods (which have dynamic IPs) to connect.

Apply the manifest and wait for ClickHouse to become ready:
```bash
kubectl create ns sentry
kubectl apply -f clickhouse.yaml
kubectl -n sentry get chi sentry-clickhouse -w
```
Wait until the `status.status` field shows `Completed` and the ClickHouse pods are `Running`:
```bash
kubectl -n sentry get pods -l clickhouse.altinity.com/chi=sentry-clickhouse
```

#### 2. (Optional) Separate ClickHouse Keeper

For more robust deployments, you should run ClickHouse Keeper separately.

**Keeper Manifest (`keeper.yaml`)**:
```yaml
apiVersion: clickhouse-keeper.altinity.com/v1
kind: ClickHouseKeeperInstallation
metadata:
  name: clickhouse-keeper
  namespace: sentry
spec:
  configuration:
    clusters:
      - name: keeper-cluster
        layout:
          replicasCount: 3 # Recommended for consensus
  defaults:
    templates:
      podTemplate: keeper-pod
      volumeClaimTemplate: keeper-storage
  templates:
    podTemplates:
      - name: keeper-pod
        spec:
          containers:
            - name: clickhouse-keeper
              image: altinity/clickhouse-keeper:25.3.6.10034.altinitystable
          affinity:
            podAntiAffinity:
              requiredDuringSchedulingIgnoredDuringExecution:
                - labelSelector:
                    matchLabels:
                      clickhouse-keeper.altinity.com/chk: clickhouse-keeper
                  topologyKey: kubernetes.io/hostname
    volumeClaimTemplates:
      - name: keeper-storage
        spec:
          accessModes:
            - ReadWriteOnce
          resources:
            requests:
              storage: 10Gi
```

Wait for all 3 Keeper pods to be ready:
```bash
kubectl -n sentry get pods -l clickhouse-keeper.altinity.com/chk=clickhouse-keeper
```

If using a separate Keeper, update your `ClickHouseInstallation` config to reference it:

```yaml
apiVersion: clickhouse.altinity.com/v1
kind: ClickHouseInstallation
metadata:
  name: sentry-clickhouse
  namespace: sentry
spec:
  configuration:
    users:
      default/networks/ip:
        - "0.0.0.0/0"
      clickhouse_operator/password: "clickhouse_operator_password"
      clickhouse_operator/networks/ip:
        - "0.0.0.0/0"
    clusters:
      - name: sentry-cluster
        layout:
          shardsCount: 1
          replicasCount: 3
        templates:
          podTemplate: clickhouse
          volumeClaimTemplate: data-volume
    zookeeper:
      nodes:
        - host: chk-clickhouse-keeper-keeper-cluster-0-0.sentry.svc.cluster.local
          port: 2181
        - host: chk-clickhouse-keeper-keeper-cluster-0-1.sentry.svc.cluster.local
          port: 2181
        - host: chk-clickhouse-keeper-keeper-cluster-0-2.sentry.svc.cluster.local
          port: 2181
  templates:
    podTemplates:
      - name: clickhouse
        spec:
          containers:
            - name: clickhouse
              image: altinity/clickhouse-server:25.3.6.10034.altinitystable
          affinity:
            podAntiAffinity:
              requiredDuringSchedulingIgnoredDuringExecution:
                - labelSelector:
                    matchLabels:
                      clickhouse.altinity.com/chi: sentry-clickhouse
                  topologyKey: kubernetes.io/hostname
    volumeClaimTemplates:
      - name: data-volume
        spec:
          accessModes:
            - ReadWriteOnce
          resources:
            requests:
              storage: 20Gi
  defaults:
    replicasUseFQDN: "true"
    templates:
      podTemplate: clickhouse
      dataVolumeClaimTemplate: data-volume
```

**Note**: The `clusterName` in your Sentry `values.yaml` must match the cluster name in the manifest above (`sentry-cluster`).

### Configuring Sentry Chart

Once your ClickHouse cluster is running, configure the Sentry Helm chart to use it.

**Find the ClickHouse service name** created by the operator:
```bash
kubectl -n sentry get svc -l clickhouse.altinity.com/chi=sentry-clickhouse
```

The Altinity Operator creates services following this naming convention:
- `clickhouse-sentry-clickhouse` — main load-balanced service (recommended for single-node setups)
- `chi-sentry-clickhouse-single-node-0-0` — per-pod service for shard 0, replica 0

**Create your `values.yaml`** using the service name from the command above:
```bash
cat <<'EOF' > values.yaml
externalClickhouse:
  host: "clickhouse-sentry-clickhouse.sentry.svc.cluster.local"
  tcpPort: 9000
  httpPort: 8123
  username: "default"
  password: "" # Set if you configured a password
  database: "default"
  singleNode: false # Set to false if using a replicated cluster
  clusterName: "sentry-cluster" 
EOF
```

### Verification

After deployment, you can verify the connection by checking the logs of the `snuba-api` or `snuba-consumer` pods, or by ensuring that Sentry is processing events correctly.

## How this chart works

```
helm repo add sentry https://sentry-kubernetes.github.io/charts
helm repo update
helm install my-sentry sentry/sentry -f values.yaml --wait --timeout=1000s
```

## Values

Each chart has its own `README.md` in its directory with values and configuration instructions (for example `charts/sentry/README.md`).
See [CHANGELOG](CHANGELOG.md) for upgrade instructions and version history.

## PostgreSQL

By default, PostgreSQL is installed as part of the chart. To use an external PostgreSQL server set `postgresql.enabled` to `false` and then set `postgresql.postgresHost` and `postgresql.postgresqlPassword`. The other options (`postgresql.postgresqlDatabase`, `postgresql.postgresqlUsername` and `postgresql.postgresqlPort`) may also want changing from their default values.

To avoid issues when upgrade this chart, provide `postgresql.postgresqlPassword` for subsequent upgrades. This is due to an issue in the PostgreSQL chart where password will be overwritten with randomly generated passwords otherwise. See https://github.com/helm/charts/tree/master/stable/postgresql#upgrade for more detail.

## Persistence

This chart is capable of mounting the sentry-data PV in the Sentry worker and cron pods. This feature is disabled by default, but is needed for some advanced features such as private sourcemaps.

You may enable mounting of the sentry-data PV across worker and cron pods by changing filestore.filesystem.persistence.persistentWorkers to true. If you plan on deploying Sentry containers across multiple nodes, you may need to change your PVC's access mode to ReadWriteMany and check that your PV supports mounting across multiple nodes.

## Roadmap

- [x] Lint in Pull requests
- [x] Public availability through Github Pages
- [x] Automatic deployment through Github Actions
- [ ] Symbolicator deployment
- [x] Testing the chart in a production environment
- [ ] Improving the README
