# Single-node ClickHouse Installation

Minimum Viable Product (MVP) configuration for a single-node ClickHouse instance suitable for testing or small-scale deployments.

## Prerequisites

Install Altinity ClickHouse Operator:

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

Verify the operator is running:
```bash
kubectl -n clickhouse-operator get pods -l app.kubernetes.io/name=altinity-clickhouse-operator
```

## ClickHouse Installation

Save this as `clickhouse.yaml`:

```bash
cat <<'EOF' > clickhouse.yaml
apiVersion: clickhouse.altinity.com/v1
kind: ClickHouseInstallation
metadata:
  name: sentry-clickhouse
  namespace: sentry
spec:
  configuration:
    clusters:
      - name: single-node
        layout:
          shardsCount: 1
          replicasCount: 1
    users:
      default/networks/ip:
        - "0.0.0.0/0"
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

## Sentry Admin Secret

Create the secret for the admin password:

```bash
kubectl create secret generic sentry-admin-password \
  --from-literal=admin-password='YourStrongPassword123!' \
  --namespace sentry
```

## Configuring Sentry Chart

Find the ClickHouse service name created by the operator:
```bash
kubectl -n sentry get svc -l clickhouse.altinity.com/chi=sentry-clickhouse
```

The Altinity Operator creates services following this naming convention:
- `clickhouse-sentry-clickhouse` — main load-balanced service (recommended for single-node setups)
- `chi-sentry-clickhouse-single-node-0-0` — per-pod service for shard 0, replica 0

Create your `values.yaml` using the service name from the command above:
```bash
cat <<'EOF' > values.yaml
user:
  existingSecret: sentry-admin-password
externalClickhouse:
  host: "clickhouse-sentry-clickhouse.sentry.svc.cluster.local"
  tcpPort: 9000
  httpPort: 8123
  username: "default"
  password: ""
  database: "default"
  singleNode: true
EOF
```

## Install Sentry

```bash
helm repo add sentry https://sentry-kubernetes.github.io/charts
helm repo update
helm install -n sentry my-sentry sentry/sentry -f values.yaml --wait --timeout=1500s
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
