# Workspace feature guide

> **AI-assisted development notice**
>
> A substantial part of the functionality described in this document, as well
> as the documentation itself, was created with the assistance of artificial
> intelligence. The implementation has been statically validated with Helm
> linting and template-rendering checks, but it should still receive human code
> review and environment-specific testing before being used in production.

This document describes the features added to the workspace version of the
Sentry Helm chart on top of upstream chart 33.0.0. It covers the behavior,
configuration model, operational dependencies, rollout procedures, and
troubleshooting for:

- selectable HPA or KEDA autoscaling;
- Kafka consumer lag scaling through Prometheus and Kafka Exporter;
- the optional `prometheus-kafka-exporter` subchart;
- the ClickHouse preparation hook;
- dedicated or shared ServiceAccounts for chart components and hooks.

These features are disabled or backward-compatible by default. Existing
installations continue to use the chart-managed HorizontalPodAutoscaler unless
a workload explicitly selects KEDA. Kafka Exporter and ClickHouse preparation
also require explicit enablement.

## ServiceAccount modes

Custom ServiceAccounts remain disabled by default. With
`serviceAccount.enabled: true` and `serviceAccount.shared: false`, the chart
creates component-specific accounts such as `sentry-web`, `sentry-snuba`, and
`sentry-hooks`. Regular database and migration hooks use the hook account.
`clickhouse-prepare` is an exception: because it runs before normal release
resources exist, it always receives a dedicated pre-install/pre-upgrade hook
ServiceAccount named `<release>-sentry-clickhouse-prepare`.

Set `shared: true` when the regular first-party chart workloads and hooks
should use a single account. The ClickHouse prepare hook, Kafka Exporter and
other dependency subcharts retain their own ServiceAccount settings and are
not redirected to the shared Sentry account.

```yaml
serviceAccount:
  enabled: true
  name: sentry
  shared: true
  automountServiceAccountToken: true
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::123456789012:role/sentry
```

In shared mode the chart renders one regular first-party ServiceAccount named
`sentry` for this example. If ClickHouse prepare is enabled, its lifecycle-safe
hook ServiceAccount is rendered in addition. In dedicated mode the chart
renders only the accounts needed by enabled components, plus `sentry-hooks`
while regular hooks are enabled.
Switching modes changes `serviceAccountName` on workloads and can restart
their Pods; review RBAC and cloud workload-identity bindings before rollout.

## Architecture overview

### Autoscaling resource ownership

Every supported workload has one `autoscaling` block. The `autoscaler`
field selects which Kubernetes resource the chart renders:

| Configuration | Result |
| --- | --- |
| `enabled: false` | No chart-managed HPA or KEDA ScaledObject |
| `enabled: true, autoscaler: hpa` | One HorizontalPodAutoscaler |
| `enabled: true, autoscaler: keda` | One KEDA ScaledObject |

The default is `autoscaler: hpa`. HPA templates contain guards that prevent
them from rendering when KEDA is selected. This is important because KEDA
creates and manages an HPA internally; rendering the chart HPA at the same time
would give two controllers ownership of the same Deployment scale target.

KEDA resources are generated centrally by
`templates/keda-scaledobjects.yaml` using helpers from
`templates/_helper-keda.tpl`. The existing upstream Deployment templates are
left intact.

### Configuration precedence

KEDA settings are resolved in this order:

1. chart-wide defaults under `global.autoscaling`;
2. workload settings under the workload's `autoscaling` block;
3. per-worker settings for Sentry Taskworker.

A more specific value overrides a global value. This allows the Prometheus
address and standard thresholds to be defined once while topics, consumer
groups, replica limits, or activation thresholds remain workload-specific.

### Supported workloads

| Workload | Value path | Default scale target |
| --- | --- | --- |
| Relay | `relay.autoscaling` | `<release>-sentry-relay` |
| Sentry Web | `sentry.web.autoscaling` | `<release>-sentry-web` |
| Vroom | `vroom.autoscaling` | `<release>-sentry-vroom` |
| Snuba API | `snuba.api.autoscaling` | `<release>-sentry-snuba-api` |
| Attachments consumer | `sentry.ingestConsumerAttachments.autoscaling` | `<release>-sentry-ingest-consumer-attachments` |
| Events consumer | `sentry.ingestConsumerEvents.autoscaling` | `<release>-sentry-ingest-consumer-events` |
| Transactions consumer | `sentry.ingestConsumerTransactions.autoscaling` | `<release>-sentry-ingest-consumer-transactions` |
| Occurrences consumer | `sentry.ingestOccurrences.autoscaling` | `<release>-sentry-ingest-occurrences` |
| Taskworker | `sentry.taskWorker.autoscaling` and `workers[].autoscaling` | one Deployment per worker |

Transactions and occurrences only render when the `feature-complete` profile
is enabled. Vroom additionally requires
`sentry.features.enableProfiling: true`; its HPA or ScaledObject is suppressed
whenever the Vroom Deployment is absent.

### Adding or renaming consumer components

The supported-workload table is an explicit registry, not automatic
discovery. A new consumer Deployment must be registered in
`templates/_helper-keda.tpl` with its values path, rendered Deployment name,
Kafka topic and consumer group. Its template must omit static `spec.replicas`
when autoscaling is enabled, and an HPA template must render only when
`autoscaler: hpa` is selected.

For example, when the uptime-results consumer proposed in PR #1830 is added to
the current chart, its documented configuration should be:

```yaml
sentry:
  uptimeResults:
    enabled: true
    autoscaling:
      enabled: true
      autoscaler: keda
      minReplicas: 1
      maxReplicas: 10
      triggers:
        kafkaLag:
          enabled: true
          topic: uptime-results
          consumerGroup: uptime-results
```

This configuration becomes valid only after the component is added to the
KEDA registry; setting it against the current unregistered component does not
create a ScaledObject. Apply the same procedure to the Snuba uptime consumer,
using the topic and group actually passed to its consumer command. Confirm the
corresponding `topic` and `consumergroup` labels in Kafka Exporter before
enabling scaling.

## KEDA prerequisites

The chart renders KEDA custom resources but does not install KEDA itself.
Before enabling a KEDA workload, install a compatible KEDA operator and CRDs
and confirm that the following resource is available:

```console
kubectl api-resources | grep scaledobjects
```

If `autoscaler: keda` is selected without the KEDA CRDs and operator, the
Helm release cannot create the ScaledObject or the workload will not be
autoscaled.

## KEDA trigger types

### CPU and memory

CPU and memory triggers are suitable for HTTP/API workloads or consumers where
resource usage correlates with load.

```yaml
sentry:
  web:
    autoscaling:
      enabled: true
      autoscaler: keda
      minReplicas: 2
      maxReplicas: 10
      pollingInterval: 30
      cooldownPeriod: 300
      triggers:
        cpu:
          enabled: true
          value: "70"
        memory:
          enabled: true
          value: "75"
```

If no Kafka or Prometheus trigger is enabled, the existing
`targetCPUUtilizationPercentage` and
`targetMemoryUtilizationPercentage` settings are used as KEDA CPU/memory
targets.

### Arbitrary Prometheus query

A generic Prometheus trigger is available for Relay and other supported
workloads.

```yaml
relay:
  autoscaling:
    enabled: true
    autoscaler: keda
    minReplicas: 2
    maxReplicas: 12
    triggers:
      prometheus:
        enabled: true
        serverAddress: http://prometheus-operated.monitoring.svc:9090
        query: sum(rate(relay_buffer_envelope_body_size_count[2m])) or vector(0)
        threshold: "30"
        activationThreshold: "5"
```

Supported optional fields include `namespace`, `customHeaders`,
`ignoreNullValues`, `unsafeSsl`, and `authenticationRef`.

### Native KEDA Kafka scaler

The native Kafka trigger connects directly to Kafka:

```yaml
global:
  autoscaling:
    pollingInterval: 30
    cooldownPeriod: 300
    triggers:
      kafka:
        lagThreshold: "1000"
        activationLagThreshold: "0"
        offsetResetPolicy: latest

sentry:
  ingestConsumerEvents:
    autoscaling:
      enabled: true
      autoscaler: keda
      minReplicas: 1
      maxReplicas: 35
      triggers:
        kafka:
          enabled: true
```

For known consumers, topic and consumer group defaults are supplied by the
chart. `bootstrapServers` defaults to the Kafka connection used by Sentry.
They can be overridden under the workload trigger.

Optional Kafka metadata includes `allowIdleConsumers`,
`scaleToZeroOnInvalidOffset`, `excludePersistentLag`,
`limitToPartitionsWithLag`, `version`, `partitionLimitation`, `sasl`,
`tls`, and `unsafeSsl`. Set `authenticationRef` to reference a KEDA
`TriggerAuthentication` for native Kafka credentials.

Helm rendering fails if KEDA is selected without any effective Kafka, Kafka
lag, Prometheus, CPU or memory trigger. `minReplicas: 0` is preserved for
scale-to-zero rather than being replaced by the default value.

Helm also rejects unknown `autoscaler` values and invalid replica/timing
bounds. Valid KEDA settings satisfy `minReplicas >= 0`, `maxReplicas >= 1`,
`minReplicas <= maxReplicas`, `pollingInterval >= 1`, and
`cooldownPeriod >= 0`.

### Service-name length validation

First-party and enabled Redis/PostgreSQL dependency Service names are checked
against Kubernetes' 63-character DNS label limit. Helm rendering stops with
the generated name and its length when a Service would exceed the limit or
dependency truncation could cause a collision. Shorten the release name or set
an appropriate `fullnameOverride`, `redis.fullnameOverride`, or
`postgresql.fullnameOverride`. The chart does not silently truncate
first-party component suffixes because that could make workload references
ambiguous.

## Kafka Exporter subchart

The chart has an optional dependency on
`prometheus-kafka-exporter` version 3.1.0, aliased as `kafkaExporter`.
It is disabled by default.

```yaml
kafkaExporter:
  enabled: true
  kafkaServer:
    - sentry-kafka.sentry.svc.cluster.local:9092
  prometheus:
    serviceMonitor:
      enabled: true
      namespace: monitoring
      additionalLabels:
        release: kube-prometheus-stack
```

The value in `kafkaServer` must be a broker address reachable from the
exporter Pod. It is not derived dynamically from the parent release name.
Always set it explicitly for the target environment.

When ServiceMonitor is enabled:

- the Prometheus Operator CRDs must exist;
- the ServiceMonitor namespace must be watched by Prometheus;
- `additionalLabels` must match the Prometheus selector;
- network policies must allow Prometheus to scrape the exporter service.

If the Prometheus Operator is not used, leave ServiceMonitor disabled and
configure Prometheus service discovery separately.

### Consumer lag through Kafka Exporter

The `kafkaLag` trigger uses KEDA's Prometheus scaler. KEDA queries Prometheus,
and Prometheus reads `kafka_consumergroup_lag` from Kafka Exporter.

```text
Kafka -> Kafka Exporter -> Prometheus -> KEDA -> Deployment replicas
```

Define shared Prometheus and threshold settings globally:

```yaml
global:
  autoscaling:
    pollingInterval: 30
    cooldownPeriod: 300
    triggers:
      kafkaLag:
        serverAddress: http://prometheus-operated.monitoring.svc:9090
        metricName: kafka_consumergroup_lag
        threshold: "1000"
        activationThreshold: "10"
```

Enable lag scaling on a consumer:

```yaml
sentry:
  ingestConsumerEvents:
    autoscaling:
      enabled: true
      autoscaler: keda
      minReplicas: 1
      maxReplicas: 35
      triggers:
        kafkaLag:
          enabled: true
```

The generated query is:

```promql
sum(kafka_consumergroup_lag{topic="ingest-events",consumergroup="ingest-consumer"})
```

Known defaults are:

| Consumer | Topic | Consumer group |
| --- | --- | --- |
| Attachments | `ingest-attachments` | `ingest-consumer` |
| Events | `ingest-events` | `ingest-consumer` |
| Transactions | `ingest-transactions` | `ingest-consumer` |
| Occurrences | `ingest-occurrences` | `ingest-occurrences` |

Override labels when the deployed consumer configuration differs:

```yaml
triggers:
  kafkaLag:
    enabled: true
    topic: custom-events
    consumerGroup: custom-ingest-consumer
```

Before rollout, verify the exact metric and labels in Prometheus:

```promql
count by (topic, consumergroup) (kafka_consumergroup_lag)
```

Then verify the intended query returns one numeric result. An empty result may
prevent scaling; a permanently stale series may cause incorrect scaling.

### Taskworker caution

Taskworker consumes work through Taskbroker rather than directly consuming the
Kafka topic itself. Kafka lag can be an early backlog signal, but it may not
match actual Taskworker backlog when Taskbroker drains Kafka faster than
workers process tasks. Validate the correlation before enabling `kafkaLag`
for Taskworker. CPU/memory or a dedicated Taskbroker queue metric may be safer.

## Scaling behavior and tuning

Important values:

| Value | Meaning |
| --- | --- |
| `minReplicas` | Lower replica bound |
| `maxReplicas` | Upper replica bound |
| `pollingInterval` | Seconds between KEDA metric checks |
| `cooldownPeriod` | Delay before scaling back toward the minimum |
| `threshold` | Target lag or Prometheus value per scaling decision |
| `activationThreshold` | Value below which the scaler is inactive |
| `advanced` | KEDA advanced/HPA behavior passed to the ScaledObject |

Start with conservative `maxReplicas`. For Kafka consumers, the useful
parallelism may be bounded by topic partition count. Increasing replicas beyond
available partitions can create idle consumers and unnecessary churn.

## KEDA rollout procedure

1. Install KEDA and verify its CRDs.
2. Enable Kafka Exporter and verify its `/metrics` endpoint.
3. Confirm Prometheus scrapes the exporter target.
4. Run the exact lag query in Prometheus.
5. Enable `kafkaLag` for one low-risk consumer.
6. Render the release and verify that it contains one ScaledObject and no
   chart-managed HPA for the target.
7. Deploy and observe KEDA operator logs, generated HPA, replica count, lag,
   consumer rebalances, and processing latency.
8. Expand to additional consumers after the first workload is stable.

Rollback a workload by setting `autoscaler: hpa`, or disable chart-managed
autoscaling entirely with `enabled: false`.

## ClickHouse prepare hook

The optional ClickHouse preparation Job runs as a
`pre-install,pre-upgrade` Helm hook. It is disabled by default.

Its responsibilities are:

1. connect to the configured external ClickHouse endpoint;
2. verify the configured cluster exists in `system.clusters`;
3. validate shard count and replicas per shard;
4. create the Snuba database if it does not exist;
5. optionally create or alter the configured runtime user;
6. optionally grant database and cluster privileges;
7. optionally apply required user settings;
8. verify runtime settings;
9. create temporary local and Distributed tables;
10. insert test rows and verify that all expected shards receive data;
11. remove the temporary tables.

A failed check exits non-zero and blocks the Helm install or upgrade.

### Credential model

The hook has no separate username or password. It uses the same credentials as
the rest of the chart:

- `externalClickhouse.username`;
- `externalClickhouse.password`; or
- `externalClickhouse.existingSecret` and
  `externalClickhouse.existingSecretKey`.

The configured account therefore needs every permission required by the
enabled prepare operations. Use an existing Kubernetes Secret instead of a
plain password in production.

### Basic configuration

```yaml
hooks:
  enabled: true
  removeOnSuccess: true

externalClickhouse:
  host: clickhouse.example.svc
  tcpPort: 9000
  httpPort: 8123
  database: sentry
  username: sentry
  existingSecret: clickhouse-credentials
  existingSecretKey: password
  clusterName: sentry_local
  distributedClusterName: sentry_distributed

  prepare:
    enabled: true
    expectedShards: 2
    expectedReplicasPerShard: 3
    backoffLimit: 20
    activeDeadlineSeconds: 1800
    ttlSecondsAfterFinished: 3600
```

`clusterName` is required when the hook is enabled.
`distributedClusterName` defaults to `clusterName`.

### Runtime user and grants

```yaml
externalClickhouse:
  prepare:
    runtimeUser:
      enabled: true
      grantAll: false
      grantOption: false
      grants:
        - SELECT
        - INSERT
        - CREATE
        - ALTER
        - DROP
        - TRUNCATE
        - OPTIMIZE
      clusterGrants:
        - CLUSTER
        - REMOTE
```

With `grantAll: false`, database grants are applied to
`externalClickhouse.database`, while cluster grants are applied to `*.*`.
With `grantAll: true`, the account receives `ALL ON *.*`. Review this mode
carefully before enabling it.

Because the prepare connection and runtime user are now the same
`externalClickhouse.username`, enabling `runtimeUser.enabled` makes the Job
create or alter the account it is currently using. The account must already
exist and be privileged enough to alter itself, or the connection must be
accepted by an external authentication configuration. Leave this option
disabled when the user is managed by a ClickHouse Operator, XML configuration,
or another identity system.

### Required settings

```yaml
externalClickhouse:
  prepare:
    settings:
      apply: false
      verify: true
      values:
        insert_distributed_one_random_shard: "1"
        distributed_foreground_insert: "1"
        skip_unavailable_shards: "0"
        load_balancing: random
```

When `apply: true`, the Job runs `ALTER USER ... SETTINGS`. When
`verify: true`, it reads `system.settings` through the runtime connection
and fails if the values differ. If settings are managed externally, leave
`apply: false` and ensure the expected values are already effective, or
disable verification deliberately.

### Distributed INSERT test

```yaml
externalClickhouse:
  prepare:
    distributedInsertTest:
      enabled: true
      maxBatches: 64
      rowsPerBatch: 10
```

The Job creates temporary ReplicatedMergeTree and Distributed tables, inserts
batches until every expected shard has data, validates total row count, and
drops the tables on exit. The runtime account needs CREATE, INSERT, SELECT, and
DROP privileges plus the required cluster access.

Disable this test only when those temporary DDL permissions are intentionally
unavailable and cluster behavior is verified elsewhere.

### Hook scheduling and Pod customization

The following values are supported:

- `image.repository`, `image.tag`, and `image.pullPolicy`;
- `resources`;
- `affinity`, `nodeSelector`, and `tolerations`;
- Pod and container security contexts;
- Pod labels and annotations;
- additional environment variables;
- sidecars;
- volumes and volume mounts.

Global selectors, tolerations, sidecars, volumes, and volume mounts are used
when applicable.

## ClickHouse rollout procedure

1. Verify the ClickHouse account can connect with `clickhouse-client`.
2. Query `system.clusters` and record cluster names, shards, and replicas.
3. Set `clusterName`, `distributedClusterName`,
   `expectedShards`, and `expectedReplicasPerShard`.
4. Decide whether user management and settings are controlled by Helm or an
   external operator.
5. Render the chart and inspect the prepare Job.
6. Run the Job in a non-production environment.
7. Review logs and confirm temporary tables are removed.
8. Enable the hook for production upgrades.

To bypass the hook during an incident, set
`externalClickhouse.prepare.enabled: false`. Understand that this skips the
preflight checks; it does not correct the underlying ClickHouse issue.

## Rendering and validation

Recommended static checks:

```console
helm dependency build
helm lint charts/sentry
helm template sentry charts/sentry -f values.yaml > rendered.yaml
```

Check autoscaler exclusivity:

```console
grep -E '^kind: (HorizontalPodAutoscaler|ScaledObject)$' rendered.yaml
```

Check the prepare hook:

```console
grep -n 'clickhouse-prepare' rendered.yaml
```

A KEDA consumer should have exactly one ScaledObject and no chart-managed HPA.
The ClickHouse prepare Job should appear only when both `hooks.enabled` and
`externalClickhouse.prepare.enabled` are true.

## Troubleshooting

### ScaledObject is missing

Verify:

- workload `enabled` is true;
- `autoscaling.enabled` is true;
- `autoscaling.autoscaler` is exactly `keda`;
- the workload profile is enabled;
- Helm is using the intended values file.

### Both HPA and ScaledObject appear

This should not happen for the migrated workloads. Confirm the HPA is not
created by another chart, GitOps resource, or a previous release. Remove the
external HPA owner before enabling KEDA.

### Kafka lag query is empty

Verify:

- Kafka Exporter can reach every broker;
- Prometheus lists the exporter target as up;
- metric name is `kafka_consumergroup_lag`;
- label names are `topic` and `consumergroup`;
- the consumer group has committed offsets;
- the Prometheus URL is reachable from the KEDA operator namespace.

### Consumer does not scale down

Inspect persistent lag, partition availability, cooldown period, activation
threshold, and KEDA-generated HPA behavior. A partition with a permanently
unavailable offset may keep lag above zero.

### ClickHouse prepare reports wrong topology

Run:

```sql
SELECT
  cluster,
  shard_num,
  replica_num,
  host_name
FROM system.clusters
ORDER BY cluster, shard_num, replica_num;
```

Confirm the Helm cluster name and expected counts match the returned topology.

### ClickHouse settings verification fails

Query the effective values using the same account used by the Job:

```sql
SELECT name, value
FROM system.settings
WHERE name IN (
  'insert_distributed_one_random_shard',
  'distributed_foreground_insert',
  'skip_unavailable_shards',
  'load_balancing'
);
```

If settings are profile-managed, update the expected values or leave
`settings.apply` disabled.

### Distributed INSERT test fails

Check:

- CREATE/DROP/INSERT/SELECT privileges;
- CLUSTER and REMOTE grants;
- ZooKeeper or ClickHouse Keeper health;
- ReplicatedMergeTree paths and macros;
- distributed cluster name;
- shard reachability;
- `skip_unavailable_shards` and load-balancing settings.

## Related files

- `Chart.yaml`: Kafka Exporter dependency.
- `Chart.lock`: locked dependency version.
- `values.yaml`: defaults and feature configuration.
- `templates/_helper-keda.tpl`: autoscaler and trigger rendering.
- `templates/keda-scaledobjects.yaml`: supported workload mappings.
- `templates/hooks/clickhouse-prepare.job.yaml`: ClickHouse preflight Job.
- `docs/keda-scaling.md`: concise KEDA guide.
- `docs/clickhouse-prepare.md`: concise ClickHouse prepare guide.
