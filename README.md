# Sentry helm charts

Sentry is a cross-platform crash reporting and aggregation platform.

## External ClickHouse Configuration

Bundled ClickHouse chart dependencies are legacy and may receive limited updates. It is recommended to use an externally managed ClickHouse deployment, such as [Altinity ClickHouse Operator](https://github.com/Altinity/clickhouse-operator).

### Step 1: Install Altinity ClickHouse Operator

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

### Step 2: Install ClickHouse Keeper

For production environments, deploy a high-availability cluster with 3 ClickHouse replicas and 3 ClickHouse Keeper nodes. For single-node testing, see [clickhouse-single-install.md](clickhouse-single-install.md).

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
          replicasCount: 3
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

Apply and wait for all 3 Keeper pods to be ready:
```bash
kubectl create ns sentry
kubectl apply -f keeper.yaml
kubectl -n sentry get pods -l clickhouse-keeper.altinity.com/chk=clickhouse-keeper -w
```

### Step 3: Install ClickHouse

**ClickHouse Manifest (`clickhouse.yaml`)**:
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
    replicasUseFQDN: "yes"
    templates:
      podTemplate: clickhouse
      dataVolumeClaimTemplate: data-volume
```

Apply and wait until the `status.status` field shows `Completed` and all ClickHouse pods are `Running`:
```bash
kubectl apply -f clickhouse.yaml
kubectl -n sentry get chi sentry-clickhouse -w
```

Verify:
```bash
kubectl -n sentry get pods -l clickhouse.altinity.com/chi=sentry-clickhouse
```

### Step 4: Create Sentry Admin Secret

```bash
kubectl create secret generic sentry-admin-password \
  --from-literal=admin-password='YourStrongPassword123!' \
  --namespace sentry
```

### Step 5: Configure and Install Sentry

Find the ClickHouse service name created by the operator:
```bash
kubectl -n sentry get svc -l clickhouse.altinity.com/chi=sentry-clickhouse
```

The Altinity Operator creates services following this naming convention:
- `clickhouse-sentry-clickhouse` — main load-balanced service
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
  password: "" # Set if you configured a password
  database: "default"
  singleNode: false
  clusterName: "sentry-cluster"
EOF
```

**Note**: The `clusterName` in your Sentry `values.yaml` must match the cluster name in the ClickHouse manifest above (`sentry-cluster`).

Install Sentry from the Helm repo:
```bash
helm repo add sentry https://sentry-kubernetes.github.io/charts
helm repo update
helm install -n sentry my-sentry sentry/sentry -f values.yaml --wait --timeout=2400s
```

Or from GHCR (OCI). Harbor proxy caches need this path:
```bash
helm install -n sentry my-sentry oci://ghcr.io/sentry-kubernetes/charts/sentry --version <chart-version> -f values.yaml --wait --timeout=2400s
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
