{{- define "sentry.snuba.config" -}}
{{- $redisPass := include "sentry.redis.password" . -}}
{{- $redisSsl  := include "sentry.redis.ssl" . -}}
settings.py: |
  import os

  from snuba.settings import *

  env = os.environ.get

  DEBUG = env("DEBUG", "0").lower() in ("1", "true")

{{- if .Values.kafka.enabled -}}
  {{ if .Values.kafka.provisioning.enabled }}

  # Set partition counts for provisioning topics from kafka chart.
  TOPIC_PARTITION_COUNTS = {
    {{- $numPartitions := .Values.kafka.provisioning.numPartitions -}}
    {{- range .Values.kafka.provisioning.topics }}
    {{ .name | quote }}: {{ default $numPartitions .partitions }},
    {{- end }}
  }
  {{- end -}}
{{- end }}

  {{- if ((.Values.kafkaTopicOverrides).prefix) }}
  SENTRY_CHARTS_KAFKA_TOPIC_PREFIX = {{ .Values.kafkaTopicOverrides.prefix | quote }}

  from snuba.utils.streams.topics import Topic
  for topic in Topic:
    KAFKA_TOPIC_MAP[topic.value] = f"{SENTRY_CHARTS_KAFKA_TOPIC_PREFIX}{topic.value}"
  {{- end }}

  # Clickhouse Options
  CLUSTERS = [
    {
      "host": env("CLICKHOUSE_HOST", {{ include "sentry.clickhouse.host" . | quote }}),
      "port": int({{ include "sentry.clickhouse.port" . }}),
      "user":  env("CLICKHOUSE_USER", "default"),
      "password": env("CLICKHOUSE_PASSWORD", ""),
      "max_connections": int(os.environ.get("CLICKHOUSE_MAX_CONNECTIONS", 100)),
      "database": env("CLICKHOUSE_DATABASE", "default"),
      "http_port": {{ include "sentry.clickhouse.http_port" . }},
      "storage_sets": {
          "cdc",
          "discover",
          "events",
          "events_ro",
          "metrics",
          "migrations",
          "outcomes",
          "querylog",
          "sessions",
          "transactions",
          "profiles",
          "functions",
          "replays",
          "generic_metrics_sets",
          "generic_metrics_distributions",
          "search_issues",
          "generic_metrics_counters",
          "spans",
          "events_analytics_platform",
          "group_attributes",
          "generic_metrics_gauges",
          "metrics_summaries",
          "profile_chunks",
      },
      {{- /*
        The default clickhouse installation runs in distributed mode, while the external
        clickhouse configured can be configured any way you choose
      */}}
      {{- if and .Values.externalClickhouse.singleNode (not .Values.clickhouse.enabled) }}
      "single_node": True,
      {{- else }}
      "single_node": False,
      {{- end }}
      {{- if or .Values.clickhouse.enabled (not .Values.externalClickhouse.singleNode) }}
      "cluster_name": {{ include "sentry.clickhouse.cluster.name" . | quote }},
      "distributed_cluster_name": {{ include "sentry.clickhouse.cluster.name" . | quote }},
      {{- end }}
    },
  ]

  # Redis Options
  REDIS_HOST = {{ include "sentry.redis.host" . | quote }}
  REDIS_PORT = {{ include "sentry.redis.port" . }}
  {{- if or (not ($redisPass)) (.Values.externalRedis.existingSecret) (.Values.redis.auth.existingSecret) }}
  REDIS_PASSWORD = env("REDIS_PASSWORD", "")
  {{- else if $redisPass }}
  REDIS_PASSWORD = {{ $redisPass | quote }}
  {{- end }}

  {{- if .Values.redis.enabled }}
  REDIS_DB = int(env("REDIS_DB", {{ default 1 .Values.redis.db }}))
  {{- else }}
  REDIS_DB = int(env("REDIS_DB", {{ default 1 .Values.externalRedis.db }}))
  {{- end }}

  {{- if eq $redisSsl "true" }}
  REDIS_SSL = True
  {{- end }}

{{- if .Values.metrics.enabled }}
  DOGSTATSD_HOST = "{{ template "sentry.fullname" . }}-metrics"
  DOGSTATSD_PORT = 9125
{{- end }}

  {{ .Values.config.snubaSettingsPy | nindent 2 }}
{{- end -}}
