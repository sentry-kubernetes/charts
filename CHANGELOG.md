# Changelog

The changelog below refers to the main `sentry` chart only.

## Upgrading to Chart 33.0.0

Chart `33.0.0` targets [Sentry 26.7.0](https://github.com/getsentry/self-hosted/releases/tag/26.7.0).

### Breaking: TaskBroker Kafka config

TaskBroker no longer uses legacy `TASKBROKER_KAFKA_TOPIC` / `TASKBROKER_KAFKA_CONSUMER_GROUP` env vars. Each `sentry.taskBroker.brokers[]` entry must provide `kafkaDeadletterTopic`, `kafkaRetryTopic`, and `kafkaTopics` (YAML config mounted into the broker). Cluster address/auth use `TASKBROKER_KAFKA_CLUSTERS__DEFAULT__*`.

**Before:**

```yaml
sentry:
  taskBroker:
    brokers:
      - name: default
        topic: taskworker
        consumerGroup: taskworker
```

**After:** see default `values.yaml` (`kafkaTopics`, including optional `raw` blocks for subscription results and profiles).

Hyphenated topic names require the YAML config file; they cannot be set via env vars. See the [taskbroker Kafka config migration guide](https://github.com/getsentry/taskbroker/blob/main/docs/kafka-config-migration.md).

### Breaking: Removed Sentry consumers (moved to TaskBroker raw mode)

These Deployments and related values keys are **removed**. Work is consumed by TaskBroker `raw` topics (products broker for subscription results; ingest broker for `profiles`):

- `sentry.subscriptionConsumerEvents`
- `sentry.subscriptionConsumerTransactions`
- `sentry.subscriptionConsumerMetrics`
- `sentry.subscriptionConsumerGenericMetrics`
- `sentry.subscriptionConsumerResultsEapItems`
- `sentry.ingestProfiles`

Remove any overrides for these keys from your values. Snuba subscription scheduler/executor Deployments (`snuba.subscriptionConsumer*`) are unchanged.

### Other

- Feature flags: workflow-engine UI and transactions→spans migration banners
- Kafka consumers default `maxPollIntervalMs: 300000` (parity with self-hosted `SENTRY_KAFKA_MAX_POLL_INTERVAL_MS`); set a consumer's `maxPollIntervalMs: null` to omit `--max-poll-interval-ms`
- When using ingress-nginx, set `nginx.ingress.kubernetes.io/proxy-read-timeout: "90"` (self-hosted nginx `proxy_read_timeout` bump)

## Upgrading to Chart 32.0.0

- **Rust Snuba consumer** is now enabled by default. Set `snuba.rustConsumer: false` to revert.
- Removed deprecated `distutils.strtobool` from `sentry.conf.py` template — mail TLS/SSL now uses `.lower() in ("true", "1", "yes")`.

## Upgrading to Chart 31.7.0

Chart `31.7.0` adds configuration for [Sentry 26.5.0](https://github.com/getsentry/self-hosted/releases/tag/26.5.0) that was not included when `appVersion` was bumped in `31.4.0`:

- **Launchpad taskworker** (default `feature-complete` profile): new `launchpad-taskworker` Deployment and `LAUNCHPAD_RPC_SHARED_SECRET` on Sentry pods.
- **Trace Metrics**: related `organizations:tracemetrics-*` feature flags are enabled in generated `sentry.conf.py`.

### Launchpad RPC shared secret

When Launchpad is enabled (`launchpadTaskWorker.enabled=true`, the default with `feature-complete`), the chart automatically creates a shared RPC secret (`<release-fullname>-launchpad-secret`) via a Helm hook on both install and upgrade. The secret is only created if it does not already exist, so existing secrets are preserved.

If you do not need Launchpad, set `launchpadTaskWorker.enabled=false`, or use the `errors-only` profile.

## Upgrading to Chart 31.x.x

> [!CAUTION]
> `31.0.0` has issues with Snuba migration, please skip this release and upgrade
> straight to `31.1.0` instead.

**Breaking change:** the insecure default Sentry admin password (`user.password: aaaa`) has been removed. When `user.create` is `true` (the default), you must now set **one** of:

- `user.existingSecret` (recommended): name of a Kubernetes Secret containing the admin password.
- `user.password`: plaintext password (not recommended for production).

If neither is set, `helm install` / `helm upgrade` will fail at template time with a clear error message instead of silently creating an admin account with a well-known password. Existing deployments that relied on the default must set one of the above before their next upgrade.

Example using an existing Secret:

```
kubectl create secret generic sentry-admin-password \
  --from-literal=admin-password='CHANGE_ME'

helm upgrade sentry sentry/sentry \
  --set user.existingSecret=sentry-admin-password
```

**Breaking change:** bash-script Kafka topic provisioning for external Kafka has been replaced with `segmentio/topicctl` ([#2157](https://github.com/sentry-kubernetes/charts/pull/2157)).

The `externalKafka.provisioning.image` block has been removed and replaced with `externalKafka.provisioning.topicctl`. Users who were using external Kafka provisioning must update their `values.yaml`:

**Before:**

```yaml
externalKafka:
  provisioning:
    image:
      repository: apache/kafka
      tag: "latest"
```

**After:**

```yaml
externalKafka:
  provisioning:
    topicctl:
      image:
        repository: segment/topicctl
        tag: "v2.0.2"
      clusterName: "sentry-kafka"
      environment: "default"
      region: "default"
      placementStrategy: "any"
```

## Upgrading to Chart 30.x.x

> [!CAUTION]
> `30.4.0` has issues with Snuba migration, please skip this release and upgrade
> straight to `31.1.0` instead.

**Breaking change:** HTTP health probe tuning for in-cluster traffic is no longer a single set of flat `probe*` values.

- **relay**, **sentry.web**, **vroom**: replace `probeFailureThreshold`, `probeInitialDelaySeconds`, `probePeriodSeconds`, `probeSuccessThreshold`, and `probeTimeoutSeconds` with nested **`livenessProbe`** and **`readinessProbe`** objects (each supports the same five fields). Defaults keep liveness tolerant and use a shorter readiness interval and lower failure threshold so pods leave Service endpoints sooner when the health HTTP endpoint fails.
- **snuba.api**: replace `probeInitialDelaySeconds`, `liveness.timeoutSeconds`, and `readiness.timeoutSeconds` with **`livenessProbe`** / **`readinessProbe`** blocks.
- **symbolicator.api**: replace `probeInitialDelaySeconds` with **`livenessProbe`** / **`readinessProbe`** blocks.
- **metrics**: if you relied on defaults, readiness is slightly stricter than liveness (`readinessProbe.periodSeconds` / `failureThreshold`); override under `metrics.readinessProbe` if needed.
- **GKE** `BackendConfig` health checks for relay/web still follow **liveness** timings (`*.livenessProbe.*`), not readiness.

See `charts/sentry/README.md` (Configuration) and `values.yaml` for the exact structure.

## Upgrading to Chart 29.x.x

- Routing is now **opt-in**: all routing options are **disabled by default**. Choose and enable **exactly one** of `ingress.enabled`, `route.main.enabled`, `traefikIngressRoute.enabled`, or `nginx.enabled`.
- When you use Kubernetes Ingress / Gateway API / Traefik, traffic is routed directly to `web`/`relay` to avoid an extra proxy hop and improve throughput.
- Optional in-cluster NGINX service support is available via the CloudPirates `nginx` chart dependency. Enable it with `nginx.enabled=true` when you need a single service endpoint or nginx-specific routing snippets. Do not run another router in front of it.

Migration guidance:

- If you **do not** want an in-cluster nginx proxy, keep `nginx.enabled=false` and enable exactly one of `ingress.enabled`, `route.main.enabled`, or `traefikIngressRoute.enabled`.
- If you **do** want an in-cluster nginx proxy, set `nginx.enabled=true` and keep `ingress.enabled`, `route.main.enabled`, and `traefikIngressRoute.enabled` disabled. Expose the `*-nginx` service directly (for example with `nginx.service.type=LoadBalancer`).
- `ingress.alb.httpRedirect` was removed. For ALB HTTP→HTTPS redirect, set `alb.ingress.kubernetes.io/listen-ports` and `alb.ingress.kubernetes.io/ssl-redirect` in `ingress.annotations`.
- Ingress templates now assume the stable `networking.k8s.io/v1` API.
- Subpath routing options were removed (`route.main.path`, `traefikIngressRoute.path`); Sentry must be served at `/`.
- If you previously relied on `nginx.extraLocationSnippet`, either keep using it with `nginx.enabled=true` or move the logic to ingress/controller configuration (annotations, controller ConfigMap) or dedicated routing objects via `extraManifests`.

Nginx Ingress, Traefik Ingress, GCE and AWS ALB are currently supported, pull requests for other controllers are welcome!

Routing changes: see the [routing section](charts/sentry/README.md#routing) for the supported modes and configuration details.

### External ClickHouse

Removed bundled ClickHouse. Use an external ClickHouse deployment and follow the [External ClickHouse guide](charts/sentry/docs/external-clickhouse.md).

### Memcached chart switch

This release replaces the Bitnami Memcached dependency with the CloudPirates Memcached chart (`oci://registry-1.docker.io/cloudpirates/memcached`). Values have changed accordingly:

- `memcached.args` and `memcached.extraEnvVarsCM` were removed.
- `memcached.memoryLimit` is now `memcached.config.memoryLimit` (value in MB).
- `memcached.maxItemSize` must be configured via `memcached.config.extraArgs` using the `-I` flag.

Example:

```yaml
memcached:
  config:
    memoryLimit: 2048
    extraArgs:
      - "-I"
      - "26214400"
```

## Upgrading to Chart 28.x.x

### Storage Configuration Changes

This release introduces significant changes to how Sentry handles storage for `nodestore` (raw events) and `profiling`. We strongly recommend using an external S3-compatible storage provider (e.g., AWS S3, Google Cloud Storage, MinIO) for these components to ensure performance and scalability, however, `nodestore` can be very write heavy (if you have tons of throughput), so take this into consideration (cloud bills).

- **Nodestore**: You can now configure S3-based node storage via `nodestore.s3`.
- **Profiles**: The `filestore.profiles` section now supports an S3 backend. Using the `filesystem` backend is discouraged for production environments.

If you require a self-hosted S3-compatible storage solution, we recommend [SeaweedFS](https://github.com/seaweedfs/seaweedfs/tree/master/k8s/charts/seaweedfs), which can be deployed using its official Helm chart.

### Clickhouse

This release necessitates ClickHouse features introduced in v24.8. As this chart will henceforth require users to manage their own services, the bundled ClickHouse version is no longer compatible. You must provision your own cluster and migrate your data from the old one prior to upgrading. We recommend using the Altinity Kubernetes Operator: https://altinity.com/kubernetes-operator/

### RabbitMQ Removed

The RabbitMQ dependency has been removed in favor of a new task broker architecture. Please review the `taskBroker` and `taskWorker` sections in `values.yaml`.

## Upgrading from 26.x.x Version of This Chart to 27.x.x

Make sure to upgrade to chart version 26.22.0 before upgrading to 27.x.x. There is a hard stop on the Sentry version.

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
- rabbit > 8.32.2 - latest 3.9.\* image version of chart
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
