# Sentry helm charts

Sentry is a cross-platform crash reporting and aggregation platform.

This repository aims to support Sentry >=10 and move out from the deprecated Helm charts official repo.

Big thanks to the maintainers of the [deprecated chart](https://github.com/helm/charts/tree/master/stable/sentry). This work has been partly inspired by it.

## External ClickHouse Configuration

### Background

Due to changes in the Bitnami chart catalog and container image policies (see [Issue #1828](https://github.com/sentry-kubernetes/charts/issues/1828)), the bundled ClickHouse chart dependencies are considered legacy and may receive limited updates.

It is strongly recommended to use an externally managed ClickHouse deployment. This ensures you have control over updates, backups, and high availability configurations independent of the Sentry chart.

The recommended way to deploy ClickHouse on Kubernetes is using the [Altinity ClickHouse Operator](https://github.com/Altinity/clickhouse-operator).

### Prerequisites

1.  **Install Altinity ClickHouse Operator**:
    Follow the [official installation guide](https://github.com/Altinity/clickhouse-operator#quick-start).

    **Important**: By default, the operator might only watch for resources in its own namespace. If you deploy ClickHouse in a different namespace, you must configure the operator to watch that namespace or all namespaces.
    
    Example `values.yaml` for the operator to watch all namespaces:
    ```yaml
    configs:
      files:
        config.yaml:
          watch:
            namespaces: [""]
    ```

### MVP Deployment with ClickHouse Keeper

Below is a Minimum Viable Product (MVP) configuration for a single-node ClickHouse instance suitable for testing or small-scale deployments. For production, we recommend a high-availability setup with at least 3 Keeper nodes and 2 ClickHouse replicas.

#### 1. ClickHouse Installation Manifest

Save this as `clickhouse.yaml`. This example deploys a single-node cluster.

```yaml
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
```

**Note on Network Access**: The `users/default/networks/ip` setting is crucial. By default, ClickHouse might restrict access. Setting it to `0.0.0.0/0` allows the Sentry pods (which have dynamic IPs) to connect.

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
        metadata:
          containers:
            - name: clickhouse-keeper
              image: altinity/clickhouse-keeper:25.3.6.10034.altinitystable
        spec:
          affinity:
            podAntiAffinity:
              requiredDuringSchedulingIgnoredDuringExecution:
                - labelSelector:
                    matchLabels:
                      app: clickhouse-keeper
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

If using a separate Keeper, update your `ClickHouseInstallation` config to reference it:

```yaml
spec:
  configuration:
    zookeeper:
      nodes:
        - host: keeper-clickhouse-keeper.sentry.svc.cluster.local
          port: 2181
```

### Configuring Sentry Chart

Once your ClickHouse cluster is running, configure the Sentry Helm chart to use it.

In your `values.yaml`:

```yaml
externalClickhouse:
  host: "clickhouse-sentry-clickhouse.sentry.svc" # Service name of your CHI
  tcpPort: 9000
  httpPort: 8123
  username: "default"
  password: "" # Set if you configured a password
  database: "default"
  singleNode: true # Set to false if using a replicated cluster
```

### Verification

After deployment, you can verify the connection by checking the logs of the `snuba-api` or `snuba-consumer` pods, or by ensuring that Sentry is processing events correctly.

## How this chart works

```
helm repo add sentry https://sentry-kubernetes.github.io/charts
helm repo update
helm install my-sentry sentry/sentry --wait --timeout=1000s
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
