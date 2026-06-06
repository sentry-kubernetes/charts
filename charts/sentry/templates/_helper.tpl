{{/* vim: set filetype=mustache: */}}

{{- define "relay.port" -}}{{ default 3000 .Values.relay.service.port }}{{- end -}}
{{- define "relay.healthCheck.readinessRequestPath" -}}/api/relay/healthcheck/ready/{{- end -}}
{{- define "relay.healthCheck.livenessRequestPath" -}}/api/relay/healthcheck/live/{{- end -}}
{{- define "sentry.port" -}}9000{{- end -}}
{{- define "sentry.healthCheck.requestPath" -}}/_health/{{- end -}}
{{- define "relay.healthCheck.requestPath" -}}/api/relay/healthcheck/live/{{- end -}}
{{- define "snuba.port" -}}1218{{- end -}}
{{- define "symbolicator.port" -}}3021{{- end -}}
{{- define "vroom.port" -}}8085{{- end -}}

{{/*
  livenessProbe block for kafka-consumer / worker deployments that expose a
  file-based healthcheck via `--healthcheck-file-path` / `--health-check-file`.

  Arguments (dict):
    livenessProbe:   the workload's .Values.<x>.livenessProbe value
    healthcheckFile: file path (default: /tmp/health.txt)
    freshnessSeconds: liveness treshold since last touch of healthcheckFile (default: 60)
*/}}
{{- define "sentry.livenessProbe.execHealthcheckFile" -}}
{{- $probe := .livenessProbe -}}
{{- if $probe.enabled -}}
{{- $probeConfig := omit $probe "enabled" "freshnessSeconds" -}}
{{- $file := default "/tmp/health.txt" .healthcheckFile -}}
{{- $fresh := default 60 $probe.freshnessSeconds -}}
livenessProbe:
  exec:
    command:
      - sh
      - -c
      - 'test $(($(date +%s) - $(stat -c %Y {{ $file }} 2>/dev/null || echo 0))) -lt {{ $fresh }}'
{{- with $probeConfig }}
{{- toYaml . | nindent 2 }}
{{- end }}
{{- end -}}
{{- end -}}

{{/*
  startupProbe block for kafka-consumer / worker deployments.
  Absorbs cold-start latency so liveness can't fire during startup.

  Arguments (dict):
    startupProbe:    the workload's .Values.<x>.startupProbe value (may be unset)
    healthcheckFile: file path (default: /tmp/health.txt)
*/}}
{{- define "sentry.startupProbe.execHealthcheckFile" -}}
{{- $probe := .startupProbe | default (dict) -}}
{{- $enabled := true -}}
{{- if hasKey $probe "enabled" -}}{{- $enabled = $probe.enabled -}}{{- end -}}
{{- if $enabled -}}
{{- $defaults := dict "periodSeconds" 5 "failureThreshold" 60 -}}
{{- $probeConfig := omit (merge (deepCopy $probe) $defaults) "enabled" -}}
{{- $file := default "/tmp/health.txt" .healthcheckFile -}}
startupProbe:
  exec:
    command:
      - test
      - -f
      - {{ $file }}
{{- with $probeConfig }}
{{- toYaml . | nindent 2 }}
{{- end }}
{{- end -}}
{{- end -}}

{{- define "relay.image" -}}
{{- default "ghcr.io/getsentry/relay" .Values.images.relay.repository -}}
:
{{- default .Chart.AppVersion .Values.images.relay.tag -}}
{{- end -}}
{{- define "sentry.image" -}}
{{- default "ghcr.io/getsentry/sentry" .Values.images.sentry.repository -}}
:
{{- default .Chart.AppVersion .Values.images.sentry.tag -}}
{{- end -}}
{{- define "snuba.image" -}}
{{- default "ghcr.io/getsentry/snuba" .Values.images.snuba.repository -}}
:
{{- default .Chart.AppVersion .Values.images.snuba.tag -}}
{{- end -}}

{{- define "symbolicator.image" -}}
{{- default "ghcr.io/getsentry/symbolicator" .Values.images.symbolicator.repository -}}
:
{{- default .Chart.AppVersion .Values.images.symbolicator.tag -}}
{{- end -}}

{{- define "dbCheck.image" -}}
{{- default "busybox" .Values.hooks.dbCheck.image.repository -}}
:
{{- default "1.38.0" .Values.hooks.dbCheck.image.tag -}}
{{- end -}}

{{- define "vroom.image" -}}
{{- default "ghcr.io/getsentry/vroom" .Values.images.vroom.repository -}}
:
{{- default .Chart.AppVersion .Values.images.vroom.tag -}}
{{- end -}}

{{- define "uptimeChecker.image" -}}
{{- default "ghcr.io/getsentry/uptime-checker" .Values.images.uptimeChecker.repository -}}
:
{{- default .Chart.AppVersion .Values.images.uptimeChecker.tag -}}
{{- end -}}

{{- define "taskbroker.image" -}}
{{- default "ghcr.io/getsentry/taskbroker" .Values.images.taskbroker.repository -}}
:
{{- default .Chart.AppVersion .Values.images.taskbroker.tag -}}
{{- end -}}

{{- define "launchpad.image" -}}
{{- default "ghcr.io/getsentry/launchpad" .Values.images.launchpad.repository -}}
:
{{- default .Chart.AppVersion .Values.images.launchpad.tag -}}
{{- end -}}

{{- define "launchpad.secretName" -}}
{{- printf "%s-launchpad-secret" (include "sentry.fullname" .) -}}
{{- end -}}

{{- define "launchpad.enabled" -}}
{{- if and (has "feature-complete" .Values.profiles) .Values.launchpadTaskWorker.enabled .Values.sentry.taskBroker.enabled -}}true{{- end -}}
{{- end -}}

{{/*
Expand the name of the chart.
*/}}
{{- define "sentry.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "sentry.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "sentry.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}


{{/*
Resolve ingress controller style for path rules.
*/}}
{{- define "sentry.ingress.controller" -}}
  {{- $style := default "" .Values.ingress.regexPathStyle -}}
  {{- if $style -}}
    {{- if or (eq $style "alb") (eq $style "aws-alb") -}}
      {{- print "alb" -}}
    {{- else if or (eq $style "gce") (eq $style "gke") (eq $style "gce-internal") -}}
      {{- print "gce" -}}
    {{- else -}}
      {{- $style -}}
    {{- end -}}
  {{- else if .Values.ingress.ingressClassName -}}
    {{- $class := .Values.ingress.ingressClassName -}}
    {{- if or (eq $class "alb") (eq $class "aws-alb") -}}
      {{- print "alb" -}}
    {{- else if or (eq $class "gce") (eq $class "gke") (eq $class "gce-internal") -}}
      {{- print "gce" -}}
    {{- else if eq $class "traefik" -}}
      {{- print "traefik" -}}
    {{- else -}}
      {{- print "nginx" -}}
    {{- end -}}
  {{- else -}}
    {{- print "nginx" -}}
  {{- end -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "sentry.postgresql.fullname" -}}
{{- if .Values.postgresql.fullnameOverride -}}
{{- .Values.postgresql.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.postgresql.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name "sentry-postgresql" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "sentry.redis.fullname" -}}
{{- if .Values.redis.fullnameOverride -}}
{{- .Values.redis.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.redis.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name "sentry-redis" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "sentry.kafka.fullname" -}}
{{- printf "%s-%s" .Release.Name "kafka" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Set postgres host
*/}}
{{- define "sentry.postgresql.host" -}}
{{- if .Values.postgresql.enabled -}}
{{- template "sentry.postgresql.fullname" . -}}
{{- else -}}
{{ required "A valid .Values.externalPostgresql.host is required" .Values.externalPostgresql.host }}
{{- end -}}
{{- end -}}
{{/*
Set postgres port
*/}}
{{- define "sentry.postgresql.port" -}}
{{- if .Values.postgresql.enabled -}}
{{- default 5432 .Values.postgresql.primary.service.ports.postgresql }}
{{- else -}}
{{- required "A valid .Values.externalPostgresql.port is required" .Values.externalPostgresql.port -}}
{{- end -}}
{{- end -}}

{{/*
Set postgresql username
*/}}
{{- define "sentry.postgresql.username" -}}
{{- if .Values.postgresql.enabled -}}
{{- default "postgres" .Values.postgresql.postgresqlUsername }}
{{- else -}}
{{ required "A valid .Values.externalPostgresql.username is required" .Values.externalPostgresql.username }}
{{- end -}}
{{- end -}}

{{/*
Set postgresql database
*/}}
{{- define "sentry.postgresql.database" -}}
{{- if .Values.postgresql.enabled -}}
{{- default "sentry" .Values.postgresql.postgresqlDatabase }}
{{- else -}}
{{ required "A valid .Values.externalPostgresql.database is required" .Values.externalPostgresql.database }}
{{- end -}}
{{- end -}}

{{/*
Set redis host
*/}}
{{- define "sentry.redis.host" -}}
{{- if .Values.redis.enabled -}}
{{- template "sentry.redis.fullname" . -}}-master
{{- else -}}
{{ required "A valid .Values.externalRedis.host is required" .Values.externalRedis.host }}
{{- end -}}
{{- end -}}
{{/*
Set redis port
*/}}
{{- define "sentry.redis.port" -}}
{{- if .Values.redis.enabled -}}
{{- default 6379 .Values.redis.redisPort }}
{{- else -}}
{{ required "A valid .Values.externalRedis.port is required" .Values.externalRedis.port }}
{{- end -}}
{{- end -}}

{{/*
Set redis password
*/}}
{{- define "sentry.redis.password" -}}
{{- if and (.Values.redis.enabled) (.Values.redis.auth.enabled) -}}
{{ .Values.redis.auth.password }}
{{- else if .Values.externalRedis.password -}}
{{ .Values.externalRedis.password }}
{{- else }}
{{- end -}}
{{- end -}}

{{/*
Set redis db
*/}}
{{- define "sentry.redis.db" -}}
{{- if .Values.redis.enabled -}}
{{ default 0 .Values.redis.db }}
{{- else -}}
{{ default 0 .Values.externalRedis.db }}
{{- end -}}
{{- end -}}

{{/*
Set redis ssl
*/}}
{{- define "sentry.redis.ssl" -}}
{{- if .Values.redis.enabled -}}
{{ default false .Values.redis.ssl }}
{{- else -}}
{{ default false .Values.externalRedis.ssl }}
{{- end -}}
{{- end -}}

{{/*
Build full Redis URI, including creds and db when available
*/}}
{{- define "sentry.redis.uri" -}}
{{- $redisHost := include "sentry.redis.host" . -}}
{{- $redisPort := include "sentry.redis.port" . -}}
{{- $redisDb   := include "sentry.redis.db" . -}}
{{- $redisProto := ternary "rediss" "redis" (eq (include "sentry.redis.ssl" .) "true") -}}
{{- $password := include "sentry.redis.password" . -}}
{{- if or (and .Values.redis.enabled .Values.redis.auth.existingSecret) (.Values.externalRedis.existingSecret) -}}
{{ printf "%s://:$(HELM_CHARTS_SENTRY_REDIS_PASSWORD_CONTROLLED)@%s:%s/%s" $redisProto $redisHost $redisPort $redisDb }}
{{- else if $password -}}
{{ printf "%s://:%s@%s:%s/%s" $redisProto $password $redisHost $redisPort $redisDb }}
{{- else -}}
{{ printf "%s://%s:%s/%s" $redisProto $redisHost $redisPort $redisDb }}
{{- end -}}
{{- end -}}

{{/*
Set ClickHouse host
*/}}
{{- define "sentry.clickhouse.host" -}}
{{ required "A valid .Values.externalClickhouse.host is required" .Values.externalClickhouse.host }}
{{- end -}}

{{/*
Set ClickHouse port
*/}}
{{- define "sentry.clickhouse.port" -}}
{{ required "A valid .Values.externalClickhouse.tcpPort is required" .Values.externalClickhouse.tcpPort }}
{{- end -}}

{{/*
Set ClickHouse HTTP port
*/}}
{{- define "sentry.clickhouse.http_port" -}}
{{ required "A valid .Values.externalClickhouse.httpPort is required" .Values.externalClickhouse.httpPort }}
{{- end -}}

{{/*
Set ClickHouse Database
*/}}
{{- define "sentry.clickhouse.database" -}}
{{ required "A valid .Values.externalClickhouse.database is required" .Values.externalClickhouse.database }}
{{- end -}}

{{/*
Set ClickHouse User
*/}}
{{- define "sentry.clickhouse.username" -}}
{{ required "A valid .Values.externalClickhouse.username is required" .Values.externalClickhouse.username }}
{{- end -}}

{{/*
Set ClickHouse Password
*/}}
{{- define "sentry.clickhouse.password" -}}
{{ .Values.externalClickhouse.password }}
{{- end -}}

{{/*
Set ClickHouse cluster name
*/}}
{{- define "sentry.clickhouse.cluster.name" -}}
{{ required "A valid .Values.externalClickhouse.clusterName is required" .Values.externalClickhouse.clusterName }}
{{- end -}}

{{/*
Set ClickHouse distributed cluster name
*/}}
{{- define "sentry.clickhouse.distributed.cluster.name" -}}
{{ default .Values.externalClickhouse.clusterName .Values.externalClickhouse.distributedClusterName }}
{{- end -}}

{{/*
Set ClickHouse secure setting
*/}}
{{- define "sentry.clickhouse.secure" -}}
{{- if .Values.externalClickhouse.secure -}}
True
{{- end -}}
{{- end -}}

{{/*
Set ClickHouse ca_certs setting
*/}}
{{- define "sentry.clickhouse.ca_certs" -}}
{{- if .Values.externalClickhouse.ca_certs -}}
{{ .Values.externalClickhouse.ca_certs }}
{{- end -}}
{{- end -}}

{{/*
Set ClickHouse verify ca setting
*/}}
{{- define "sentry.clickhouse.verify" -}}
{{- if .Values.externalClickhouse.verify -}}
True
{{- end -}}
{{- end -}}

{{/*
Set Kafka Confluent host
*/}}
{{- define "sentry.kafka.host" -}}
{{- if .Values.kafka.enabled -}}
{{- template "sentry.kafka.fullname" . -}}
{{- else if and (.Values.externalKafka) (not (.Values.externalKafka.cluster)) -}}
{{ required "A valid .Values.externalKafka.host is required" .Values.externalKafka.host }}
{{- end -}}
{{- end -}}

{{/*
Set Kafka Confluent port
*/}}
{{- define "sentry.kafka.port" -}}
{{- if and (.Values.kafka.enabled) (.Values.kafka.service.ports.client) -}}
{{- .Values.kafka.service.ports.client }}
{{- else if and (.Values.externalKafka) (not (.Values.externalKafka.cluster)) -}}
{{ required "A valid .Values.externalKafka.port is required" .Values.externalKafka.port }}
{{- end -}}
{{- end -}}

{{/*
Set Kafka Confluent Controller port
*/}}
{{- define "sentry.kafka.controller_port" -}}
{{- if and (.Values.kafka.enabled) (.Values.kafka.service.ports.controller ) -}}
{{- .Values.kafka.service.ports.controller }}
{{- else if and (.Values.externalKafka) (not (.Values.externalKafka.cluster)) -}}
{{ required "A valid .Values.externalKafka.port is required" .Values.externalKafka.port }}
{{- end -}}
{{- end -}}

{{/*
Set Kafka bootstrap servers string
*/}}
{{- define "sentry.kafka.bootstrap_servers_string" -}}
{{- if or (.Values.kafka.enabled) (not (.Values.externalKafka.cluster)) -}}
{{ printf "%s:%s" (include "sentry.kafka.host" .) (include "sentry.kafka.port" .) }}
{{- else -}}
{{- range $index, $elem := .Values.externalKafka.cluster -}}
{{- if $index -}},{{- end -}}{{ printf "%s:%s" $elem.host (toString $elem.port) }}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
SASL auth setings for Kafka:
* https://github.com/getsentry/snuba/blob/24.11.2/snuba/settings/__init__.py#L220-L230
* https://github.com/getsentry/sentry/blob/24.11.2/src/sentry/utils/kafka_config.py#L9-L34
* https://github.com/getsentry/sentry/blob/24.11.2/src/sentry/conf/server.py#L2844-L2853
*/}}

{{/*
Set Kafka security protocol
*/}}
{{- define "sentry.kafka.security_protocol" -}}
{{- if .Values.kafka.enabled -}}
{{ default "plaintext" .Values.kafka.listeners.client.protocol }}
{{- else -}}
{{ default "plaintext" .Values.externalKafka.security.protocol }}
{{- end -}}
{{- end -}}

{{/*
Set Kafka sasl mechanism
*/}}
{{- define "sentry.kafka.sasl_mechanism" -}}
{{- $CheckProtocol := include "sentry.kafka.security_protocol" . -}}
{{- if (regexMatch "^SASL_" $CheckProtocol) -}}
{{- if .Values.kafka.enabled -}}
{{ default "None" (split "," .Values.kafka.sasl.enabledMechanisms)._0 }}
{{- else -}}
{{ default "None" .Values.externalKafka.sasl.mechanism }}
{{- end -}}
{{- else -}}
{{ "None" }}
{{- end -}}
{{- end -}}

{{/*
Set Kafka sasl username
*/}}
{{- define "sentry.kafka.sasl_username" -}}
{{- $CheckProtocol := include "sentry.kafka.security_protocol" . -}}
{{- if (regexMatch "^SASL_" $CheckProtocol) -}}
{{- if .Values.kafka.enabled -}}
{{ default "None" (first (default tuple .Values.kafka.sasl.client.users)) }}
{{- else -}}
{{ default "None" .Values.externalKafka.sasl.username }}
{{- end -}}
{{- else -}}
{{ "None" }}
{{- end -}}
{{- end -}}

{{/*
Set Kafka sasl password
*/}}
{{- define "sentry.kafka.sasl_password" -}}
{{- $CheckProtocol := include "sentry.kafka.security_protocol" . -}}
{{- if (regexMatch "^SASL_" $CheckProtocol) -}}
{{- if .Values.kafka.enabled -}}
{{ default "None" (first (default tuple .Values.kafka.sasl.client.passwords)) }}
{{- else -}}
{{ default "None" .Values.externalKafka.sasl.password }}
{{- end -}}
{{- else -}}
{{ "None" }}
{{- end -}}
{{- end -}}

{{/*
Set Senty compression.type for Kafka
*/}}
{{- define "sentry.kafka.compression_type" -}}
{{- if .Values.kafka.enabled -}}
{{ default "" .Values.sentry.kafka.compression.type }}
{{- else -}}
{{ default "" .Values.externalKafka.compression.type }}
{{- end -}}
{{- end -}}

{{/*
Set Senty message.max.bytes for Kafka
*/}}
{{- define "sentry.kafka.message_max_bytes" -}}
{{- if .Values.kafka.enabled -}}
{{ default 50000000 .Values.sentry.kafka.message.max.bytes | int64 }}
{{- else -}}
{{ default 50000000 .Values.externalKafka.message.max.bytes | int64 }}
{{- end -}}
{{- end -}}

{{/*
Set Senty socket.timeout for Kafka
*/}}
{{- define "sentry.kafka.socket_timeout_ms" -}}
{{- if .Values.kafka.enabled -}}
{{ default 1000 .Values.sentry.kafka.socket.timeout.ms | int64 }}
{{- else -}}
{{ default 1000 .Values.externalKafka.socket.timeout.ms | int64 }}
{{- end -}}
{{- end -}}

{{/*
Common Snuba environment variables
*/}}
{{- define "sentry.snuba.env" -}}
- name: SNUBA_SETTINGS
  value: /etc/snuba/settings.py
- name: DEFAULT_BROKERS
  value: {{ include "sentry.kafka.bootstrap_servers_string" . | quote }}
{{- if and (not .Values.kafka.enabled) .Values.externalKafka.sasl.existingSecret }}
- name: KAFKA_SASL_MECHANISM
  valueFrom:
    secretKeyRef:
      name: {{ .Values.externalKafka.sasl.existingSecret }}
      key: {{ default "mechanism" .Values.externalKafka.sasl.existingSecretKeys.mechanism }}
- name: KAFKA_SASL_USERNAME
  valueFrom:
    secretKeyRef:
      name: {{ .Values.externalKafka.sasl.existingSecret }}
      key: {{ default "username" .Values.externalKafka.sasl.existingSecretKeys.username }}
- name: KAFKA_SASL_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.externalKafka.sasl.existingSecret }}
      key: {{ default "password" .Values.externalKafka.sasl.existingSecretKeys.password }}
{{- else }}
{{- $sentryKafkaSaslMechanism := include "sentry.kafka.sasl_mechanism" . -}}
{{- if not (eq "None" $sentryKafkaSaslMechanism) }}
- name: KAFKA_SASL_MECHANISM
  value: {{ $sentryKafkaSaslMechanism | quote}}
{{- end }}
{{- $sentryKafkaSaslUsername := include "sentry.kafka.sasl_username" . -}}
{{- if not (eq "None" $sentryKafkaSaslUsername) }}
- name: KAFKA_SASL_USERNAME
  value: {{ $sentryKafkaSaslUsername | quote }}
{{- end }}
{{- $sentryKafkaSaslPassword := include "sentry.kafka.sasl_password" . -}}
{{- if not (eq "None" $sentryKafkaSaslPassword) }}
- name: KAFKA_SASL_PASSWORD
  value: {{ $sentryKafkaSaslPassword | quote }}
{{- end }}
{{- end }}
- name: KAFKA_SECURITY_PROTOCOL
  value: {{ include "sentry.kafka.security_protocol" . | quote }}

{{/*
Set external Redis password from existingSecret
*/}}
{{- if and (.Values.redis.enabled) (.Values.redis.auth.enabled) }}
{{- if .Values.redis.auth.password }}
- name: REDIS_PASSWORD
  value: {{ .Values.redis.auth.password | quote }}
{{- else if .Values.redis.auth.existingSecret }}
- name: REDIS_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ default (include "sentry.redis.fullname" .) .Values.redis.auth.existingSecret }}
      key: {{ default "redis-password" .Values.redis.auth.existingSecretPasswordKey }}
{{- end }}
{{- else if .Values.externalRedis.password }}
- name: REDIS_PASSWORD
  value: {{ .Values.externalRedis.password | quote }}
{{- else if .Values.externalRedis.existingSecret }}
- name: REDIS_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.externalRedis.existingSecret }}
      key: {{ default "redis-password" .Values.externalRedis.existingSecretKey }}
{{- end }}

{{/*
Set external Clickhouse password from existingSecret
*/}}
{{- if .Values.externalClickhouse.existingSecret }}
- name: CLICKHOUSE_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.externalClickhouse.existingSecret }}
      key: {{ default "clickhouse-password" .Values.externalClickhouse.existingSecretKey }}
{{- end }}
- name: CLICKHOUSE_MAX_CONNECTIONS
  value: {{ .Values.snuba.clickhouse.maxConnections | quote }}
{{- if .Values.ipv6 }}
- name: UWSGI_HTTP_SOCKET
  value: "[::]:1218"
{{- end }}
- name: REDIS_PORT
  value:  {{ default "6379" (include "sentry.redis.port" . | quote ) -}}
{{- end -}}

{{- define "vroom.env" -}}
- name: SENTRY_KAFKA_BROKERS_PROFILING
  value: {{ include "sentry.kafka.bootstrap_servers_string" . | quote }}
- name: SENTRY_KAFKA_BROKERS_OCCURRENCES
  value: {{ include "sentry.kafka.bootstrap_servers_string" . | quote }}
- name: SENTRY_BUCKET_PROFILES
  value: {{ .Values.vroom.persistence.bucketString | quote }}
- name: SENTRY_SNUBA_HOST
  value: http://{{ template "sentry.fullname" . }}-snuba:{{ template "snuba.port" . }}
{{- end -}}

{{/*
TaskBroker Kafka environment variables.
The TaskBroker binary (Rust) reads Kafka config from TASKBROKER_KAFKA_* prefixed env vars,
not the standard KAFKA_SASL_* vars used by Python-based Sentry/Snuba components.
This helper auto-injects the required TASKBROKER_KAFKA_* and TASKBROKER_KAFKA_DEADLETTER_*
env vars when externalKafka is configured with SASL authentication.
See: https://github.com/sentry-kubernetes/charts/issues/2088
*/}}
{{- define "sentry.taskbroker.kafka.env" -}}
{{- if not .Values.kafka.enabled }}
{{- $securityProtocol := include "sentry.kafka.security_protocol" . -}}
{{- $bootstrapServers := include "sentry.kafka.bootstrap_servers_string" . -}}
- name: TASKBROKER_KAFKA_SECURITY_PROTOCOL
  value: {{ $securityProtocol | quote }}
- name: TASKBROKER_KAFKA_DEADLETTER_CLUSTER
  value: {{ $bootstrapServers | quote }}
- name: TASKBROKER_KAFKA_DEADLETTER_SECURITY_PROTOCOL
  value: {{ $securityProtocol | quote }}
{{- if regexMatch "^SASL_" $securityProtocol }}
{{- if .Values.externalKafka.sasl.existingSecret }}
- name: TASKBROKER_KAFKA_SASL_MECHANISM
  valueFrom:
    secretKeyRef:
      name: {{ .Values.externalKafka.sasl.existingSecret }}
      key: {{ default "mechanism" .Values.externalKafka.sasl.existingSecretKeys.mechanism }}
- name: TASKBROKER_KAFKA_SASL_USERNAME
  valueFrom:
    secretKeyRef:
      name: {{ .Values.externalKafka.sasl.existingSecret }}
      key: {{ default "username" .Values.externalKafka.sasl.existingSecretKeys.username }}
- name: TASKBROKER_KAFKA_SASL_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.externalKafka.sasl.existingSecret }}
      key: {{ default "password" .Values.externalKafka.sasl.existingSecretKeys.password }}
- name: TASKBROKER_KAFKA_DEADLETTER_SASL_MECHANISM
  valueFrom:
    secretKeyRef:
      name: {{ .Values.externalKafka.sasl.existingSecret }}
      key: {{ default "mechanism" .Values.externalKafka.sasl.existingSecretKeys.mechanism }}
- name: TASKBROKER_KAFKA_DEADLETTER_SASL_USERNAME
  valueFrom:
    secretKeyRef:
      name: {{ .Values.externalKafka.sasl.existingSecret }}
      key: {{ default "username" .Values.externalKafka.sasl.existingSecretKeys.username }}
- name: TASKBROKER_KAFKA_DEADLETTER_SASL_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.externalKafka.sasl.existingSecret }}
      key: {{ default "password" .Values.externalKafka.sasl.existingSecretKeys.password }}
{{- else }}
{{- $saslMechanism := include "sentry.kafka.sasl_mechanism" . -}}
{{- $saslUsername := include "sentry.kafka.sasl_username" . -}}
{{- $saslPassword := include "sentry.kafka.sasl_password" . -}}
{{- if not (eq "None" $saslMechanism) }}
- name: TASKBROKER_KAFKA_SASL_MECHANISM
  value: {{ $saslMechanism | quote }}
- name: TASKBROKER_KAFKA_DEADLETTER_SASL_MECHANISM
  value: {{ $saslMechanism | quote }}
{{- end }}
{{- if not (eq "None" $saslUsername) }}
- name: TASKBROKER_KAFKA_SASL_USERNAME
  value: {{ $saslUsername | quote }}
- name: TASKBROKER_KAFKA_DEADLETTER_SASL_USERNAME
  value: {{ $saslUsername | quote }}
{{- end }}
{{- if not (eq "None" $saslPassword) }}
- name: TASKBROKER_KAFKA_SASL_PASSWORD
  value: {{ $saslPassword | quote }}
- name: TASKBROKER_KAFKA_DEADLETTER_SASL_PASSWORD
  value: {{ $saslPassword | quote }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end -}}

{{- define "launchpadTaskWorker.env" -}}
- name: LAUNCHPAD_WORKER_RPC_HOST
  value: {{ printf "%s-taskbroker-default:50051" (include "sentry.fullname" .) | quote }}
- name: LAUNCHPAD_WORKER_CONCURRENCY
  value: {{ .Values.launchpadTaskWorker.concurrency | quote }}
- name: LAUNCHPAD_WORKER_HEALTH_CHECK_FILE_PATH
  value: "/tmp/health.txt"
- name: KAFKA_BOOTSTRAP_SERVERS
  value: {{ include "sentry.kafka.bootstrap_servers_string" . | quote }}
- name: SENTRY_BASE_URL
  value: {{ printf "http://%s-web:%s" (include "sentry.fullname" .) (include "sentry.port" .) | quote }}
- name: LAUNCHPAD_ENV
  value: "self-hosted"
- name: LAUNCHPAD_RPC_SHARED_SECRET
  valueFrom:
    secretKeyRef:
      name: {{ include "launchpad.secretName" . }}
      key: rpc-shared-secret
{{- end -}}

{{- define "uptimeChecker.env" -}}
- name: UPTIME_CHECKER_RESULTS_KAFKA_CLUSTER
  value: {{ include "sentry.kafka.bootstrap_servers_string" . | quote }}
{{- /* Expose Redis password from secret if configured to avoid rendering secrets inline */}}
{{- if and (.Values.redis.enabled) (.Values.redis.auth.existingSecret) }}
- name: HELM_CHARTS_SENTRY_REDIS_PASSWORD_CONTROLLED
  valueFrom:
    secretKeyRef:
      name: {{ .Values.redis.auth.existingSecret }}
      key: {{ default "redis-password" .Values.redis.auth.existingSecretPasswordKey }}
{{- else if .Values.externalRedis.existingSecret }}
- name: HELM_CHARTS_SENTRY_REDIS_PASSWORD_CONTROLLED
  valueFrom:
    secretKeyRef:
      name: {{ .Values.externalRedis.existingSecret }}
      key: {{ default "redis-password" .Values.externalRedis.existingSecretKey }}
{{- end }}
- name: UPTIME_CHECKER_REDIS_HOST
  value: {{ include "sentry.redis.uri" . | quote }}
{{- end -}}

{{/*
Common Sentry environment variables
*/}}
{{- define "sentry.env" -}}
- name: SNUBA
  value: http://{{ template "sentry.fullname" . }}-snuba:{{ template "snuba.port" . }}
- name: VROOM
  value: http://{{ template "sentry.fullname" . }}-vroom:{{ template "vroom.port" . }}
{{- if .Values.sentry.existingSecret }}
- name: SENTRY_SECRET_KEY
  valueFrom:
    secretKeyRef:
      name: {{ .Values.sentry.existingSecret }}
      key: {{ default "key" .Values.sentry.existingSecretKey }}
{{- else }}
- name: SENTRY_SECRET_KEY
  valueFrom:
    secretKeyRef:
      name: {{ template "sentry.fullname" . }}-sentry-secret
      key: "key"
{{- end }}

{{/*
Set Kafka SASL credentials from existingSecret
*/}}
{{- if and (not .Values.kafka.enabled) .Values.externalKafka.sasl.existingSecret }}
- name: KAFKA_SASL_MECHANISM
  valueFrom:
    secretKeyRef:
      name: {{ .Values.externalKafka.sasl.existingSecret }}
      key: {{ default "mechanism" .Values.externalKafka.sasl.existingSecretKeys.mechanism }}
- name: KAFKA_SASL_USERNAME
  valueFrom:
    secretKeyRef:
      name: {{ .Values.externalKafka.sasl.existingSecret }}
      key: {{ default "username" .Values.externalKafka.sasl.existingSecretKeys.username }}
- name: KAFKA_SASL_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.externalKafka.sasl.existingSecret }}
      key: {{ default "password" .Values.externalKafka.sasl.existingSecretKeys.password }}
{{- end }}

{{/*
Set external Postgresql password from existingSecret
*/}}
{{- if .Values.postgresql.enabled }}
- name: POSTGRES_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ default (include "sentry.postgresql.fullname" .) .Values.postgresql.auth.existingSecret }}
      key: {{ default "postgres-password" .Values.postgresql.auth.secretKeys.adminPasswordKey }}
{{- else if .Values.externalPostgresql.password }}
- name: POSTGRES_PASSWORD
  value: {{ .Values.externalPostgresql.password | quote }}
{{- else if .Values.externalPostgresql.existingSecret }}
- name: POSTGRES_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.externalPostgresql.existingSecret }}
      key: {{ or .Values.externalPostgresql.existingSecretKeys.password .Values.externalPostgresql.existingSecretKey "postgresql-password" }}
{{- end }}

{{/*
Set external Postgresql user from existingSecret
*/}}
{{- if and .Values.externalPostgresql.existingSecret .Values.externalPostgresql.existingSecretKeys.username }}
- name: POSTGRES_USER
  valueFrom:
    secretKeyRef:
      name: {{ .Values.externalPostgresql.existingSecret }}
      key: {{ default .Values.externalPostgresql.existingSecretKeys.username }}
{{- else }}
- name: POSTGRES_USER
  value: {{ include "sentry.postgresql.username" . | quote }}
{{- end }}

{{/*
Set external Postgresql name from existingSecret
*/}}
{{- if and .Values.externalPostgresql.existingSecret .Values.externalPostgresql.existingSecretKeys.database }}
- name: POSTGRES_NAME
  valueFrom:
    secretKeyRef:
      name: {{ .Values.externalPostgresql.existingSecret }}
      key: {{ default .Values.externalPostgresql.existingSecretKeys.database }}
{{- else }}
- name: POSTGRES_NAME
  value: {{ include "sentry.postgresql.database" . | quote }}
{{- end }}

{{/*
Set external Postgresql host from existingSecret
*/}}
{{- if .Values.pgbouncer.enabled }}
- name: POSTGRES_HOST
  value: {{ template "sentry.fullname" . }}-pgbouncer
{{- else }}
{{- if and .Values.externalPostgresql.existingSecret .Values.externalPostgresql.existingSecretKeys.host }}
- name: POSTGRES_HOST
  valueFrom:
    secretKeyRef:
      name: {{ .Values.externalPostgresql.existingSecret }}
      key: {{ default .Values.externalPostgresql.existingSecretKeys.host }}
{{- else }}
- name: POSTGRES_HOST
  value: {{ include "sentry.postgresql.host" . | quote }}
{{- end }}
{{- end }}

{{/*
Set external Postgresql port from existingSecret
*/}}
{{- if .Values.pgbouncer.enabled }}
- name: POSTGRES_PORT
  value: "5432"
{{- else }}
{{- if and .Values.externalPostgresql.existingSecret .Values.externalPostgresql.existingSecretKeys.port }}
- name: POSTGRES_PORT
  valueFrom:
    secretKeyRef:
      name: {{ .Values.externalPostgresql.existingSecret }}
      key: {{ default .Values.externalPostgresql.existingSecretKeys.port }}
{{- else }}
- name: POSTGRES_PORT
  value: {{ include "sentry.postgresql.port" . | quote }}
{{- end }}
{{- end }}

{{/*
Set S3
*/}}
{{- if and (eq .Values.filestore.backend "s3") .Values.filestore.s3.existingSecret }}
- name: S3_ACCESS_KEY_ID
  valueFrom:
    secretKeyRef:
      name: {{ .Values.filestore.s3.existingSecret }}
      key: {{ default "s3-access-key-id" .Values.filestore.s3.accessKeyIdRef }}
- name: S3_SECRET_ACCESS_KEY
  valueFrom:
    secretKeyRef:
      name: {{ .Values.filestore.s3.existingSecret }}
      key: {{ default "s3-secret-access-key" .Values.filestore.s3.secretAccessKeyRef }}
{{- end }}

{{/*
Set Replay S3
*/}}
{{- if and (eq .Values.replay.storage.backend "s3") .Values.replay.storage.s3.existingSecret }}
- name: REPLAY_S3_ACCESS_KEY_ID
  valueFrom:
    secretKeyRef:
      name: {{ .Values.replay.storage.s3.existingSecret }}
      key: {{ default "s3-access-key-id" .Values.replay.storage.s3.accessKeyIdRef }}
- name: REPLAY_S3_SECRET_ACCESS_KEY
  valueFrom:
    secretKeyRef:
      name: {{ .Values.replay.storage.s3.existingSecret }}
      key: {{ default "s3-secret-access-key" .Values.replay.storage.s3.secretAccessKeyRef }}
{{- end }}

{{/*
Set Profiles S3
*/}}
{{- if and (eq .Values.filestore.profiles.backend "s3") (.Values.filestore.profiles.s3) (.Values.filestore.profiles.s3.existingSecret) }}
- name: PROFILES_S3_ACCESS_KEY_ID
  valueFrom:
    secretKeyRef:
      name: {{ .Values.filestore.profiles.s3.existingSecret }}
      key: {{ default "s3-access-key-id" .Values.filestore.profiles.s3.accessKeyIdRef }}
- name: PROFILES_S3_SECRET_ACCESS_KEY
  valueFrom:
    secretKeyRef:
      name: {{ .Values.filestore.profiles.s3.existingSecret }}
      key: {{ default "s3-secret-access-key" .Values.filestore.profiles.s3.secretAccessKeyRef }}
{{- end }}

{{/*
Set Nodestore S3
*/}}
{{- if and (eq .Values.nodestore.backend "s3") (.Values.nodestore.s3) (.Values.nodestore.s3.existingSecret) }}
- name: NODESTORE_S3_ACCESS_KEY_ID
  valueFrom:
    secretKeyRef:
      name: {{ .Values.nodestore.s3.existingSecret }}
      key: {{ default "s3-access-key-id" .Values.nodestore.s3.accessKeyIdRef }}
- name: NODESTORE_S3_SECRET_ACCESS_KEY
  valueFrom:
    secretKeyRef:
      name: {{ .Values.nodestore.s3.existingSecret }}
      key: {{ default "s3-secret-access-key" .Values.nodestore.s3.secretAccessKeyRef }}
{{- end }}

{{/*
Set redis password
*/}}
{{- if .Values.redis.enabled }}
{{- if .Values.redis.password }}
- name: REDIS_PASSWORD
  value: {{ .Values.redis.password | quote }}
{{- else if .Values.redis.existingSecret }}
- name: REDIS_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ default (include "sentry.redis.fullname" .) .Values.redis.existingSecret }}
      key: {{ default "redis-password" .Values.redis.existingSecretKey }}
{{- end }}
{{- else if .Values.externalRedis.password }}
- name: REDIS_PASSWORD
  value: {{ .Values.externalRedis.password | quote }}
{{- else if .Values.externalRedis.existingSecret }}
- name: REDIS_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.externalRedis.existingSecret }}
      key: {{ default "redis-password" .Values.externalRedis.existingSecretKey }}
{{- end }}


{{- if and (.Values.redis.enabled) (.Values.redis.auth.existingSecret) }}
- name: HELM_CHARTS_SENTRY_REDIS_PASSWORD_CONTROLLED
  valueFrom:
    secretKeyRef:
      name: {{ .Values.redis.auth.existingSecret }}
      key: {{ default "redis-password" .Values.redis.auth.existingSecretPasswordKey }}
- name: BROKER_URL
  value: {{ include "sentry.redis.uri" . | quote }}
{{- else if (.Values.externalRedis.existingSecret) }}
- name: HELM_CHARTS_SENTRY_REDIS_PASSWORD_CONTROLLED
  valueFrom:
    secretKeyRef:
      name: {{ .Values.externalRedis.existingSecret }}
      key: {{ default "redis-password" .Values.externalRedis.existingSecretKey }}
- name: BROKER_URL
  value: {{ include "sentry.redis.uri" . | quote }}
{{- end }}

{{/*
Set google application
*/}}
{{- $gcsSecretName := include "sentry.gcs.secretName" . -}}
{{- $gcsCredentialsFile := include "sentry.gcs.credentialsFile" . -}}
{{- if and $gcsSecretName $gcsCredentialsFile }}
- name: GOOGLE_APPLICATION_CREDENTIALS
  value: /var/run/secrets/google/{{ $gcsCredentialsFile }}
{{- end }}

{{/*
Set sentry email password
*/}}
{{- if .Values.mail.password }}
- name: SENTRY_EMAIL_PASSWORD
  value: {{ .Values.mail.password | quote }}
{{- else if .Values.mail.existingSecret }}
- name: SENTRY_EMAIL_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.mail.existingSecret }}
      key: {{ default "mail-password" .Values.mail.existingSecretKey }}
{{- end }}

{{/*
Set slack
*/}}
{{- if .Values.slack.existingSecret }}
- name: SLACK_CLIENT_ID
  valueFrom:
    secretKeyRef:
      name: {{ .Values.slack.existingSecret }}
      key: {{ default "client-id" .Values.slack.existingSecretClientId }}
- name: SLACK_CLIENT_SECRET
  valueFrom:
    secretKeyRef:
      name: {{ .Values.slack.existingSecret }}
      key: {{ default "client-secret" .Values.slack.existingSecretClientSecret }}
- name: SLACK_SIGNING_SECRET
  valueFrom:
    secretKeyRef:
      name: {{ .Values.slack.existingSecret }}
      key: {{ default "signing-secret" .Values.slack.existingSecretSigningSecret }}
{{- end }}

{{/*
Set discord
*/}}
{{- if .Values.discord.existingSecret }}
- name: DISCORD_APPLICATION_ID
  valueFrom:
    secretKeyRef:
      name: {{ .Values.discord.existingSecret }}
      key: {{ default "application-id" .Values.discord.existingSecretApplicationId }}
- name: DISCORD_PUBLIC_KEY
  valueFrom:
    secretKeyRef:
      name: {{ .Values.discord.existingSecret }}
      key: {{ default "public-key" .Values.discord.existingSecretPublicKey }}
- name: DISCORD_CLIENT_SECRET
  valueFrom:
    secretKeyRef:
      name: {{ .Values.discord.existingSecret }}
      key: {{ default "client-secret" .Values.discord.existingSecretClientSecret }}
- name: DISCORD_BOT_TOKEN
  valueFrom:
    secretKeyRef:
      name: {{ .Values.discord.existingSecret }}
      key: {{ default "bot-token" .Values.discord.existingSecretBotToken }}
{{- end }}

{{/*
Set github app
*/}}
{{- if and .Values.github.existingSecret }}
- name: GITHUB_APP_PRIVATE_KEY
  valueFrom:
    secretKeyRef:
      name: {{ .Values.github.existingSecret }}
      key: {{ default "private-key" .Values.github.existingSecretPrivateKeyKey }}
- name: GITHUB_APP_WEBHOOK_SECRET
  valueFrom:
    secretKeyRef:
      name: {{ .Values.github.existingSecret }}
      key: {{ default "webhook-secret" .Values.github.existingSecretWebhookSecretKey }}
- name: GITHUB_APP_CLIENT_ID
  valueFrom:
    secretKeyRef:
      name: {{ .Values.github.existingSecret }}
      key: {{ default "client-id" .Values.github.existingSecretClientIdKey }}
- name: GITHUB_APP_CLIENT_SECRET
  valueFrom:
    secretKeyRef:
      name: {{ .Values.github.existingSecret }}
      key: {{ default "client-secret" .Values.github.existingSecretClientSecretKey }}
{{- if .Values.github.existingSecretAppIdKey }}
- name: GITHUB_APP_ID
  valueFrom:
    secretKeyRef:
      name: {{ .Values.github.existingSecret }}
      key: {{ .Values.github.existingSecretAppIdKey }}
{{- end }}
{{- if .Values.github.existingSecretAppNameKey }}
- name: GITHUB_APP_NAME
  valueFrom:
    secretKeyRef:
      name: {{ .Values.github.existingSecret }}
      key: {{ .Values.github.existingSecretAppNameKey }}
{{- end }}
{{- end }}

{{/*
Set google auth
*/}}
{{- if .Values.google.existingSecret }}
- name: GOOGLE_AUTH_CLIENT_ID
  valueFrom:
    secretKeyRef:
      name: {{ .Values.google.existingSecret }}
      key: {{ default "client-id" .Values.google.existingSecretClientIdKey }}
- name: GOOGLE_AUTH_CLIENT_SECRET
  valueFrom:
    secretKeyRef:
      name: {{ .Values.google.existingSecret }}
      key: {{ default "client-secret" .Values.google.existingSecretClientSecretKey }}
{{- end }}

{{/*
Set openai api
*/}}
{{- if .Values.openai.existingSecret }}
- name: OPENAI_API_KEY
  valueFrom:
    secretKeyRef:
      name: {{ .Values.openai.existingSecret }}
      key: {{ default "api-token" .Values.openai.existingSecretKey }}
{{- end }}

{{/*
Set JS SDK Loader assets setup
*/}}
{{- if .Values.sentry.jsSdk.setupAssets }}
- name: SETUP_JS_SDK_ASSETS
  value: "1"
{{- end }}

{{/*
Launchpad RPC shared secret (required by Sentry web and launchpad-taskworker)
*/}}
{{- if eq (include "launchpad.enabled" .) "true" }}
- name: LAUNCHPAD_RPC_SHARED_SECRET
  valueFrom:
    secretKeyRef:
      name: {{ include "launchpad.secretName" . }}
      key: rpc-shared-secret
{{- end }}
{{- end -}}

{{- define "sentry.autoscaling.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "autoscaling/v2" -}}
{{- print "autoscaling/v2" -}}
{{- else -}}
{{- print "autoscaling/v1" -}}
{{- end -}}
{{- end -}}


{{/*
Pgbouncer environment variables
*/}}
{{- define "sentry.pgbouncer.env" -}}
{{- if and .Values.externalPostgresql.existingSecret .Values.externalPostgresql.existingSecretKeys.host }}
- name: POSTGRESQL_HOST
  valueFrom:
    secretKeyRef:
      name: {{ .Values.externalPostgresql.existingSecret }}
      key: {{ default .Values.externalPostgresql.existingSecretKeys.host }}
{{- else }}
- name: POSTGRESQL_HOST
  value: {{ include "sentry.postgresql.host" . | quote }}
{{- end }}
{{- if and .Values.externalPostgresql.existingSecret .Values.externalPostgresql.existingSecretKeys.port }}
- name: POSTGRESQL_PORT
  valueFrom:
    secretKeyRef:
      name: {{ .Values.externalPostgresql.existingSecret }}
      key: {{ default .Values.externalPostgresql.existingSecretKeys.port }}
{{- else }}
- name: POSTGRESQL_PORT
  value: {{ include "sentry.postgresql.port" . | quote }}
{{- end }}
{{- if and .Values.externalPostgresql.existingSecret .Values.externalPostgresql.existingSecretKeys.database }}
- name: PGBOUNCER_DATABASE
  valueFrom:
    secretKeyRef:
      name: {{ .Values.externalPostgresql.existingSecret }}
      key: {{ default .Values.externalPostgresql.existingSecretKeys.database }}
{{- else }}
- name: PGBOUNCER_DATABASE
  value: {{ include "sentry.postgresql.database" . | quote }}
{{- end }}
{{- if .Values.postgresql.enabled }}
- name: POSTGRESQL_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ default (include "sentry.postgresql.fullname" .) .Values.postgresql.auth.existingSecret }}
      key: {{ default "postgres-password" .Values.postgresql.auth.secretKeys.adminPasswordKey }}
{{- else if .Values.externalPostgresql.password }}
- name: POSTGRESQL_PASSWORD
  value: {{ .Values.externalPostgresql.password | quote }}
{{- else if .Values.externalPostgresql.existingSecret }}
- name: POSTGRESQL_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.externalPostgresql.existingSecret }}
      key: {{ or .Values.externalPostgresql.existingSecretKeys.password .Values.externalPostgresql.existingSecretKey "postgresql-password" }}
{{- end }}
{{- if and .Values.externalPostgresql.existingSecret .Values.externalPostgresql.existingSecretKeys.username }}
- name: POSTGRESQL_USERNAME
  valueFrom:
    secretKeyRef:
      name: {{ .Values.externalPostgresql.existingSecret }}
      key: {{ default .Values.externalPostgresql.existingSecretKeys.username }}
{{- else }}
- name: POSTGRESQL_USERNAME
  value: {{ include "sentry.postgresql.username" . | quote }}
{{- end }}
{{- end -}}

{{/*
GCS settings for filestore/replay/profiles storage.
*/}}
{{- define "sentry.gcs.sharedValue" -}}
{{- $ctx := .ctx -}}
{{- $field := .field -}}
{{- $filestoreGcs := default dict $ctx.Values.filestore.gcs -}}
{{- $replayGcs := default dict $ctx.Values.replay.storage.gcs -}}
{{- $profilesGcs := default dict $ctx.Values.filestore.profiles.gcs -}}

{{- /* Collect all GCS-backed field configs as a list of (backend, value, name) tuples */ -}}
{{- $sources := list
  (dict "backend" $ctx.Values.filestore.backend          "value" (default "" (index $filestoreGcs $field)) "name" (printf "filestore.gcs.%s" $field))
  (dict "backend" $ctx.Values.replay.storage.backend     "value" (default "" (index $replayGcs $field))    "name" (printf "replay.storage.gcs.%s" $field))
  (dict "backend" $ctx.Values.filestore.profiles.backend "value" (default "" (index $profilesGcs $field))  "name" (printf "filestore.profiles.gcs.%s" $field))
-}}

{{- /* Filter to only active GCS sources */ -}}
{{- $gcsSources := list -}}
{{- range $sources -}}
  {{- if eq .backend "gcs" -}}
    {{- $gcsSources = append $gcsSources . -}}
  {{- end -}}
{{- end -}}

{{- /* Cross-check all pairs: if both have a value set, they must match */ -}}
{{- range $i, $a := $gcsSources -}}
  {{- range $j, $b := $gcsSources -}}
    {{- if and (gt $j $i) $a.value $b.value (ne $a.value $b.value) -}}
      {{- fail (printf "When using GCS for multiple backends, %s and %s must match." $a.name $b.name) -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{- /* Return the first non-empty value found among active GCS sources */ -}}
{{- range $gcsSources -}}
  {{- if .value -}}
    {{- .value -}}
    {{- break -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{- define "sentry.gcs.secretName" -}}
{{- include "sentry.gcs.sharedValue" (dict "ctx" . "field" "secretName") -}}
{{- end -}}

{{- define "sentry.gcs.credentialsFile" -}}
{{- include "sentry.gcs.sharedValue" (dict "ctx" . "field" "credentialsFile") -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "sentry.labels" -}}
helm.sh/chart: {{ include "sentry.chart" . }}
{{ include "sentry.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "sentry.selectorLabels" -}}
app.kubernetes.io/name: {{ include "sentry.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Component labels
*/}}
{{- define "sentry.component.labels" -}}
helm.sh/chart: {{ include "sentry.chart" .ctx }}
{{ include "sentry.component.selectorLabels" (dict "component" .component "ctx" .ctx) }}
{{- if .ctx.Chart.AppVersion }}
app.kubernetes.io/version: {{ .ctx.Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .ctx.Release.Service }}
{{- end }}

{{/*
Component selector labels
Actually not used as selector but split in this case.
*/}}
{{- define "sentry.component.selectorLabels" -}}
app.kubernetes.io/name: {{ include "sentry.name" .ctx }}
app.kubernetes.io/instance: {{ .ctx.Release.Name }}
app.kubernetes.io/component: {{ .component }}
{{- end }}

{{/*
Return the appropriate apiVersion for Gateway API HTTPRoute.
Returns empty string if Gateway API is not available in the cluster.
Gateway API v1 is GA since Kubernetes 1.29.
*/}}
{{- define "sentry.route.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "gateway.networking.k8s.io/v1" -}}
{{- print "gateway.networking.k8s.io/v1" -}}
{{- else if .Capabilities.APIVersions.Has "gateway.networking.k8s.io/v1beta1" -}}
{{- print "gateway.networking.k8s.io/v1beta1" -}}
{{- end -}}
{{- end -}}
