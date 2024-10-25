# Sentry helm charts

Sentry is a cross-platform crash reporting and aggregation platform.

This repository aims to support Sentry >=10 and move out from the deprecated Helm charts official repo.

Big thanks to the maintainers of the [deprecated chart](https://github.com/helm/charts/tree/master/stable/sentry). This work has been partly inspired by it.

## How this chart works

```
helm repo add sentry https://sentry-kubernetes.github.io/charts
helm repo update
helm install my-sentry sentry/sentry --wait --timeout=1000s
```

## Values

For now the full list of values is not documented, but you can get inspired by the `values.yaml` specific to each directory.

## Upgrading from 25.x.x Version of This Chart to 26.x.x

Make sure to upgrade to chart version 25.20.0 (Sentry 24.8.0) before upgrading to 26.x.x.

## Upgrading from 23.x.x Version of This Chart to 24.x.x/25.x.x

Make sure to revert the changes on Clickhouse replica counts if the change doesn't suit you.

## Upgrading from 22.x.x Version of This Chart to 23.x.x

This version introduces changes to definitions of ingest-consumers and workers. These changes allow to balance
ingestion pipeline with more granularity.

### Major Changes

- **Ingest consumers**: Templates for Deployment and HPA manifests are now separate for ingest-consumer-events,
  ingest-consumer-attachments, and ingest-consumer-transactions.
- **Workers**: Templates for two additional worker Deployments added, each of them with its own HPA. By default, they're
  configured for error- and transaction-related tasks processing, but queues to consume can be redefined for both.

### Migration Guide

Since labels are immutable in Kubernetes Deployments, `helm upgrade --force` should be used to recreate ingest-consumer Deployments.
As an alternative, existing ingest-consumer Deployments can be removed manually with `kubectl delete` before upgrading the Helm release.

## Upgrading from 21.x.x Version of This Chart to 22.x.x

This version introduces a significant change by dropping support for Kafka Zookeeper and transitioning to Kafka Kraft
mode. This change requires action on your part to ensure a smooth upgrade.

### Major Changes

- **Kafka Upgrade**: We have upgraded from Kafka `23.0.7` to `27.1.2`. This involves moving from Zookeeper to Kraft,
  requiring a fresh setup of Kafka.

### Migration Guide

1. **Backup Your Data**: Ensure all your data is backed up before starting the migration process.
2. **Retrieve the Cluster ID from Zookeeper** by executing:

    ```shell
    kubectl exec -it <your-zookeeper-pod> -- zkCli.sh get /cluster/id
    ```

3. **Deploy at least one Kraft controller-only** in your deployment with `zookeeperMigrationMode=true`. The Kraft
    controllers will migrate the data from your Kafka ZkBroker to Kraft mode.

    To do this, add the following values to your Zookeeper deployment when upgrading:

    ```yaml
    controller:
        replicaCount: 1
        controllerOnly: true
        zookeeperMigrationMode: true
    broker:
        zookeeperMigrationMode: true
    kraft:
        enabled: true
        clusterId: "<your_cluster_id>"
    ```

4. **Wait until all brokers are ready.** You should see the following log in the broker logs:

    ```shell
    INFO [KafkaServer id=100] Finished catching up on KRaft metadata log, requesting that the KRaft controller unfence this broker (kafka.server.KafkaServer)
    INFO [BrokerLifecycleManager id=100 isZkBroker=true] The broker has been unfenced. Transitioning from RECOVERY to RUNNING. (kafka.server.BrokerLifecycleManager)
    ```
    In the controllers, the following message should show up:
    ```shell
    Transitioning ZK migration state from PRE_MIGRATION to MIGRATION (org.apache.kafka.controller.FeatureControlManager)
    ```

5. **Once all brokers have been successfully migrated,** set **`broker.zookeeperMigrationMode=false`** to fully migrate them.
    ```yaml
    broker:
      zookeeperMigrationMode: false
    ```

6. **To conclude the migration**, switch off migration mode on controllers and stop Zookeeper:

    ```yaml
    controller:
        zookeeperMigrationMode: false
    zookeeper:
        enabled: false
    ```
    After the migration is complete, you should see the following message in your controllers:

    ```shell
    [2023-07-13 13:07:45,226] INFO [QuorumController id=1] Transitioning ZK migration state from MIGRATION to POST_MIGRATION (org.apache.kafka.controller.FeatureControlManager)
    ```
7. **(Optional)** If you would like to switch to a non-dedicated cluster, set **`controller.controllerOnly=false`**. This will cause controller-only nodes to switch to controller+broker nodes.

    At this point, you could manually decommission broker-only nodes by reassigning its partitions to controller-eligible nodes.

    For more information about decommissioning a Kafka broker, check the official documentation.

## Upgrading from 20.x.x version of this Chart to 21.x.x

Bumped dependencies:
- memcached > 6.5.9
- kafka > 23.0.7 - This is a major update, but only kafka version is updated. See [bitnami charts' update note](https://github.com/bitnami/charts/tree/main/bitnami/kafka#to-2300)
- clickhouse > 3.7.0 - Supports `priorityClassName` and `max_suspicious_broken_parts` config.
- zookeeper > 11.4.11 - 2 Major updates from v9 to v11. See [To v10 upgrade notes](https://github.com/bitnami/charts/tree/main/bitnami/zookeeper#to-1000) and [To v11 upgrade notes](https://github.com/bitnami/charts/tree/main/bitnami/zookeeper#to-1100)
- rabbitmq > 11.16.2

## Upgrading from 19.x.x version of this Chart to 20.x.x

Bumped dependencies:
- kafka > 22.1.3 - now supports Kraft. Note that the upgrade is breaking and that you have to start a new Kafka from scratch to use it.

Example:

```yaml
kafka:
  zookeeper:
    enabled: false
  kraft:
    enabled: true
```

## Upgrading from 18.x.x version of this Chart to 19.x.x

Chart dependencies have been upgraded because of Sentry requirements.
Changes:
- The minimum required version of PostgreSQL is 14.5 (works with 15.x too)

Bumped dependencies:
- postgresql > 12.5.1 - latest version of chart with postgres 15

## Upgrading from 17.x.x version of this Chart to 18.x.x

If Kafka is complaining about unknown or missing topic, please connect to `kafka-0` and run

```shell
/opt/bitnami/kafka/bin/kafka-topics.sh --create --topic ingest-replay-recordings --bootstrap-server localhost:9092
```

## Upgrading from 16.x.x version of this Chart to 17.x.x

Sentry version from 22.10.0 onwards should be using chart 17.x.x

- post process forwarder events and transactions topics are split in Sentry 22.10.0

You can delete the deployment "sentry-post-process-forward" as it's no longer needed.

`sentry-worker` may fail to start by [#774](https://github.com/sentry-kubernetes/charts/issues/774).
If you encountered this issue, please reset `counters-0`, `triggers-0` queues.

## Upgrading from 15.x.x version of this Chart to 16.x.x

`system.secret-key` is removed

See https://github.com/sentry-kubernetes/charts/tree/develop/sentry#sentry-secret-key

## Upgrading from 14.x.x version of this Chart to 15.x.x

Chart dependencies have been upgraded because of bitnami charts removal.
Changes:
- `nginx.service.port: 80` > `nginx.service.ports.http: 80`
- `kafka.service.port` > `kafka.service.ports.client`

Bumped dependencies:
- redis > 16.12.1 - latest version of chart
- kafka > 16.3.2 - chart aligned with zookeeper dependency, upgraded Kafka to 3.11
- rabbit > 8.32.2 - latest 3.9.* image version of chart
- postgresql > 10.16.2 - latest version of chart with postgres 11
- nginx > 12.0.4 - latest version of chart

## Upgrading from 13.x.x version of this Chart to 14.0.0

ClickHouse was reconfigured with sharding and replication in mind. If you are using external ClickHouse, you don't need to do anything.

**WARNING**: You will lose current event data<br>
Otherwise, you should delete the old ClickHouse volumes in order to upgrade to this version.

## Upgrading from 12.x.x version of this Chart to 13.0.0

The service annotations have been moved from the `service` section to the respective service's service sub-section. So what was:

```yaml
service:
  annotations:
    alb.ingress.kubernetes.io/healthcheck-path: /_health/
    alb.ingress.kubernetes.io/healthcheck-port: traffic-port
```

will now be set per service:

```yaml
sentry:
  web:
    service:
      annotations:
        alb.ingress.kubernetes.io/healthcheck-path: /_health/
        alb.ingress.kubernetes.io/healthcheck-port: traffic-port

relay:
  service:
    annotations:
      alb.ingress.kubernetes.io/healthcheck-path: /api/relay/healthcheck/ready/
      alb.ingress.kubernetes.io/healthcheck-port: traffic-port
```

## Upgrading from 10.x.x version of this Chart to 11.0.0

If you were using ClickHouse Tabix externally, we disabled it by default.

## Upgrading from 9.x.x version of this Chart to 10.0.0

If you were using ClickHouse ImagePullSecrets, [we unified](https://github.com/sentry-kubernetes/charts/commit/573ca29d03bf2c044004c1aa387f652a36ada23a) the way it's used.

## Upgrading from 8.x.x version of this Chart to 9.0.0

To simplify first-time installations, the backup value on ClickHouse has been changed to false.

`clickhouse.clickhouse.configmap.remote_servers.replica.backup`

## Upgrading from 7.x.x version of this Chart to 8.0.0

- the default value of `features.orgSubdomains` is now "false"

## Upgrading from 6.x.x version of this Chart to 7.0.0

- the default mode of relay is now "proxy". You can change it through the `values.yaml` file
- we removed the `githubSso` variable for the OAuth GitHub configuration. It was using the old environment variable, that doesn't work with Sentry anymore. Just use the common `github.xxxx` configuration for both OAuth & the application integration.

## Upgrading from 5.x.x version of this Chart to 6.0.0

- The `sentry.configYml` value is now in a real YAML format
- If you were previously using `relay.asHook`, the value is now `asHook`

## Upgrading from 4.x.x version of this Chart to 5.0.0

As Relay is now part of this chart, you need to make sure you enable either Nginx or the Ingress. Please read the next paragraph for more information.

If you are using an ingress gateway (like Istio), you have to change your inbound path from `sentry-web` to `nginx`.

## NGINX and/or Ingress

By default, NGINX is enabled to allow sending the incoming requests to [Sentry Relay](https://getsentry.github.io/relay/) or the Django backend depending on the path. When Sentry is meant to be exposed outside of the Kubernetes cluster, it is recommended to disable NGINX and let the Ingress do the same. It's recommended to go with the go-to Ingress Controller, [NGINX Ingress](https://kubernetes.github.io/ingress-nginx/), but others should work as well.

Note: if you are using NGINX Ingress, please set this annotation on your ingress: `nginx.ingress.kubernetes.io/use-regex: "true"`.
If you are using `additionalHostNames`, the `nginx.ingress.kubernetes.io/upstream-vhost` annotation might also come in handy.
It sets the `Host` header to the value you provide to avoid CSRF issues.

### Letsencrypt on NGINX Ingress Controller
```yaml
nginx:
  ingress:
    annotations:
      cert-manager.io/cluster-issuer: "letsencrypt-prod"
    enabled: true
    hostname: fqdn
    ingressClassName: "nginx"
    tls: true
```

## ClickHouse warning

Snuba only supports a UTC timezone for ClickHouse. Please keep the initial value!

## Upgrading from 3.1.0 version of this Chart to 4.0.0

Following Helm Chart best practices, the new version introduces some breaking changes. All configuration for external
resources moved to separate config branches: `externalClickhouse`, `externalKafka`, `externalRedis`, `externalPostgresql`.

Here is a mapping table of old values and new values:

| Before                          | After                         |
| ------------------------------- | ----------------------------- |
| `postgresql.postgresqlHost`     | `externalPostgresql.host`     |
| `postgresql.postgresqlPort`     | `externalPostgresql.port`     |
| `postgresql.postgresqlUsername` | `externalPostgresql.username` |
| `postgresql.postgresqlPassword` | `externalPostgresql.password` |
| `postgresql.postgresqlDatabase` | `externalPostgresql.database` |
| `postgresql.postgresSslMode`    | `externalPostgresql.sslMode`  |
| `redis.host`                    | `externalRedis.host`          |
| `redis.port`                    | `externalRedis.port`          |
| `redis.password`                | `externalRedis.password`      |

## Upgrading from deprecated 9.0 -> 10.0 Chart

As this chart runs in Helm 3 and also tries its best to follow on from the original Sentry chart. There are some steps that need to be taken in order to correctly upgrade.

From the previous upgrade, make sure to get the following from your previous installation:

- Redis Password (If Redis auth was enabled)
- PostgreSQL Password
  Both should be in the `secrets` of your original 9.0 release. Make a note of both of these values.

#### Upgrade Steps

Due to an issue where transferring from Helm 2 to 3. StatefulSets that use the following: `heritage: {{ .Release.Service }}` in the metadata field will error out with a `Forbidden` error during the upgrade. The only workaround is to delete the existing StatefulSets (Don't worry, PVC will be retained):

> `kubectl delete --all sts -n <Sentry Namespace>`

Once the StatefulSets are deleted. Next steps is to convert the Helm release from version 2 to 3 using the Helm 3 plugin:

> `helm3 2to3 convert <Sentry Release Name>`

Finally, it's just a case of upgrading and ensuring the correct params are used:

If Redis auth enabled:

> `helm upgrade -n <Sentry namespace> <Sentry Release> . --set redis.usePassword=true --set redis.password=<Redis Password> --set postgresql.postgresqlPassword=<Postgresql Password>`

If Redis auth is disabled:

> `helm upgrade -n <Sentry namespace> <Sentry Release> . --set postgresql.postgresqlPassword=<Postgresql Password>`

Please also follow the steps for Major version 3 to 4 migration

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
