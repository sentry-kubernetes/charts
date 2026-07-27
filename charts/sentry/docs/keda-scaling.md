# KEDA autoscaling

This chart can render KEDA `ScaledObject` resources for selected workloads. The
KEDA operator and CRDs must already be installed in the cluster. An optional
`prometheus-kafka-exporter` subchart exposes Kafka consumer-group lag metrics.

Autoscaling remains backward compatible: `autoscaler: hpa` is the default. Set
`autoscaler: keda` on an enabled workload to replace its chart-managed HPA with
a `ScaledObject`.

Supported workloads are Relay, Sentry Web, Vroom, Snuba API, the attachments,
events, transactions and occurrences ingest consumers, and every configured
Sentry Taskworker.

Global trigger defaults can be configured under `global.autoscaling.triggers`.
Workload trigger values take precedence over global values.

## Kafka lag through kafka-exporter

Enable the exporter and configure the Kafka brokers it should query. Prometheus
must scrape the exporter Service; enable its ServiceMonitor when using the
Prometheus Operator.

```yaml
kafkaExporter:
  enabled: true
  kafkaServer:
    - sentry-kafka:9092
  prometheus:
    serviceMonitor:
      enabled: true
      namespace: monitoring
      additionalLabels:
        release: kube-prometheus-stack

global:
  autoscaling:
    triggers:
      kafkaLag:
        serverAddress: http://prometheus-operated.monitoring.svc:9090
        metricName: kafka_consumergroup_lag
        threshold: "1000"
        activationThreshold: "10"

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

The chart derives the known Kafka topic and consumer group from the workload.
Both can be overridden with `topic` and `consumerGroup` in `kafkaLag`. The
generated PromQL query is equivalent to:

```promql
sum(kafka_consumergroup_lag{topic="ingest-events",consumergroup="ingest-consumer"})
```

The metric and its `topic` and `consumergroup` labels must be present in the
Prometheus instance referenced by `serverAddress`.

## Native Kafka scaler

The native KEDA Kafka scaler remains available as an alternative:

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
      maxReplicas: 10
      triggers:
        kafka:
          enabled: true
```

Its Kafka bootstrap servers, topic and consumer group default to the chart's
Kafka configuration and the workload's known topic/group. They can be
overridden under the workload trigger.

Relay can use a Prometheus trigger:

```yaml
relay:
  autoscaling:
    enabled: true
    autoscaler: keda
    minReplicas: 2
    maxReplicas: 10
    triggers:
      prometheus:
        enabled: true
        serverAddress: http://prometheus.monitoring.svc:9090
        query: sum(rate(relay_buffer_envelope_body_size_count[2m])) or vector(0)
        threshold: "30"
        activationThreshold: "5"
```

CPU and memory triggers are supported through `triggers.cpu` and
`triggers.memory`. If neither Kafka nor Prometheus is enabled, the existing HPA
CPU/memory targets are used by KEDA.

At least one effective trigger is required. Helm rendering fails when KEDA is
selected but Kafka, Kafka lag, Prometheus, CPU and memory triggers are all
disabled. `minReplicas: 0` is preserved and can be used for scale-to-zero when
the selected KEDA trigger supports activation from zero.

The `autoscaler` value must be exactly `hpa` or `keda`. For KEDA,
`minReplicas`, `maxReplicas`, `pollingInterval`, and `cooldownPeriod` must be
integers. Helm also enforces `minReplicas >= 0`, `maxReplicas >= 1`,
`minReplicas <= maxReplicas`, `pollingInterval >= 1`, and
`cooldownPeriod >= 0`.

For authenticated native Kafka scalers, reference a separately managed KEDA
`TriggerAuthentication`:

```yaml
sentry:
  ingestConsumerEvents:
    autoscaling:
      enabled: true
      autoscaler: keda
      minReplicas: 0
      triggers:
        kafka:
          enabled: true
          authenticationRef: sentry-kafka-auth
```

## Connecting newly added consumers

KEDA support is explicit rather than automatic. When the chart gains another
consumer, such as the uptime-results and Snuba uptime consumers proposed in
PR #1830, adding its Deployment and values alone does not make it a KEDA scale
target. The chart change introducing the consumer must also:

1. add an `autoscaling` block with `enabled`, `autoscaler`, replica limits and
   trigger configuration;
2. register the values path, Deployment name, Kafka topic and consumer group
   in `templates/_helper-keda.tpl`;
3. suppress the static `spec.replicas` value while autoscaling is enabled;
4. guard any workload-specific HPA with `autoscaler: hpa`;
5. render tests for HPA, native Kafka, Prometheus Kafka lag and disabled modes.

For an uptime-results consumer using topic and group `uptime-results`, the
resulting user-facing configuration should follow this shape after that
consumer is registered by the chart:

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

The corresponding Snuba consumer should use its actual Kafka topic and
consumer group from the Deployment command. Do not copy the example values
blindly: verify both labels in Kafka Exporter metrics first. The same
registration rule applies to renamed consumers, because the ScaledObject's
`scaleTargetRef.name` must exactly match the rendered Deployment name.
