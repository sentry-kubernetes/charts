{{/* vim: set filetype=mustache: */}}

{{- define "sentry.prefix" -}}
    {{- if .Values.prefix -}}
        {{.Values.prefix}}-
    {{- else -}}
    {{- end -}}
{{- end -}}

{{- define "nginx.port" -}}{{ default "8080" .Values.nginx.containerPort }}{{- end -}}
{{- define "relay.port" -}}3000{{- end -}}
{{- define "relay.healthCheck.readinessRequestPath" -}}/api/relay/healthcheck/ready/{{- end -}}
{{- define "relay.healthCheck.livenessRequestPath" -}}/api/relay/healthcheck/live/{{- end -}}
{{- define "sentry.port" -}}9000{{- end -}}
{{- define "sentry.healthCheck.requestPath" -}}/_health/{{- end -}}
{{- define "relay.healthCheck.requestPath" -}}/api/relay/healthcheck/live/{{- end -}}
{{- define "snuba.port" -}}1218{{- end -}}
{{- define "symbolicator.port" -}}3021{{- end -}}
{{- define "vroom.port" -}}8085{{- end -}}

{{- define "relay.image" -}}
{{- default "getsentry/relay" .Values.images.relay.repository -}}
:
{{- default .Chart.AppVersion .Values.images.relay.tag -}}
{{- end -}}
{{- define "sentry.image" -}}
{{- default "getsentry/sentry" .Values.images.sentry.repository -}}
:
{{- default .Chart.AppVersion .Values.images.sentry.tag -}}
{{- end -}}
{{- define "snuba.image" -}}
{{- default "getsentry/snuba" .Values.images.snuba.repository -}}
:
{{- default .Chart.AppVersion .Values.images.snuba.tag -}}
{{- end -}}

{{- define "symbolicator.image" -}}
{{- default "getsentry/symbolicator" .Values.images.symbolicator.repository -}}
:
{{- default .Chart.AppVersion .Values.images.symbolicator.tag -}}
{{- end -}}

{{- define "dbCheck.image" -}}
{{- default "subfuzion/netcat" .Values.hooks.dbCheck.image.repository -}}
:
{{- default "latest" .Values.hooks.dbCheck.image.tag -}}
{{- end -}}

{{- define "vroom.image" -}}
{{- default "getsentry/vroom" .Values.images.vroom.repository -}}
:
{{- default .Chart.AppVersion .Values.images.vroom.tag -}}
{{- end -}}

{{/*
Expand the name of the chart.
*/}}
{{- define "sentry.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

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
Get KubeVersion removing pre-release information.
*/}}
{{- define "sentry.kubeVersion" -}}
  {{- default .Capabilities.KubeVersion.Version (regexFind "v[0-9]+\\.[0-9]+\\.[0-9]+" .Capabilities.KubeVersion.Version) -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for ingress.
*/}}
{{- define "sentry.ingress.apiVersion" -}}
  {{- if and (.Capabilities.APIVersions.Has "networking.k8s.io/v1") (semverCompare ">= 1.19.x" (include "sentry.kubeVersion" .)) -}}
      {{- print "networking.k8s.io/v1" -}}
  {{- else if .Capabilities.APIVersions.Has "networking.k8s.io/v1beta1" -}}
    {{- print "networking.k8s.io/v1beta1" -}}
  {{- else -}}
    {{- print "extensions/v1beta1" -}}
  {{- end -}}
{{- end -}}

{{/*
Return if ingress is stable.
*/}}
{{- define "sentry.ingress.isStable" -}}
  {{- eq (include "sentry.ingress.apiVersion" .) "networking.k8s.io/v1" -}}
{{- end -}}

{{/*
Return the appropriate batch apiVersion for cronjobs.
batch/v1beta1 will no longer be served in v1.25
See more at https://kubernetes.io/docs/reference/using-api/deprecation-guide/#cronjob-v125
*/}}
{{- define "sentry.batch.apiVersion" -}}
  {{- if and (.Capabilities.APIVersions.Has "batch/v1") (semverCompare ">= 1.21.x" (include "sentry.kubeVersion" .)) -}}
      {{- print "batch/v1" -}}
  {{- else if .Capabilities.APIVersions.Has "batch/v1beta1" -}}
    {{- print "batch/v1beta1" -}}
  {{- end -}}
{{- end -}}

{{/*
Return if batch is stable.
*/}}
{{- define "sentry.batch.isStable" -}}
  {{- eq (include "sentry.batch.apiVersion" .) "batch/v1" -}}
{{- end -}}

{{/*
Return if ingress supports ingressClassName.
*/}}
{{- define "sentry.ingress.supportsIngressClassName" -}}
  {{- or (eq (include "sentry.ingress.isStable" .) "true") (and (eq (include "sentry.ingress.apiVersion" .) "networking.k8s.io/v1beta1") (semverCompare ">= 1.18.x" (include "sentry.kubeVersion" .))) -}}
{{- end -}}

{{/*
Return if ingress supports pathType.
*/}}
{{- define "sentry.ingress.supportsPathType" -}}
  {{- or (eq (include "sentry.ingress.isStable" .) "true") (and (eq (include "sentry.ingress.apiVersion" .) "networking.k8s.io/v1beta1") (semverCompare ">= 1.18.x" (include "sentry.kubeVersion" .))) -}}
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

{{- define "sentry.rabbitmq.fullname" -}}
{{- printf "%s-%s" .Release.Name "rabbitmq" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "sentry.clickhouse.fullname" -}}
{{- printf "%s-%s" .Release.Name "clickhouse" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "sentry.kafka.fullname" -}}
{{- printf "%s-%s" .Release.Name "kafka" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "sentry.zookeeper.fullname" -}}
{{- if .Values.kafka.zookeeper.fullnameOverride -}}
{{- .Values.kafka.zookeeper.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.kafka.zookeeper.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name "zookeeper" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
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
Set postgres secret
*/}}
{{- define "sentry.postgresql.secret" -}}
{{- if .Values.postgresql.enabled -}}
{{- template "sentry.postgresql.fullname" . -}}
{{- else -}}
{{- template "sentry.fullname" . -}}
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
Set redis secret
*/}}
{{- define "sentry.redis.secret" -}}
{{- if .Values.redis.enabled -}}
{{- template "sentry.redis.fullname" . -}}
{{- else -}}
{{- template "sentry.fullname" . -}}
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
{{- if .Values.redis.enabled -}}
{{ .Values.redis.password }}
{{- else -}}
{{ .Values.externalRedis.password }}
{{- end -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "sentry.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "sentry.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Set ClickHouse host
*/}}
{{- define "sentry.clickhouse.host" -}}
{{- if .Values.clickhouse.enabled -}}
{{- template "sentry.clickhouse.fullname" . -}}
{{- else -}}
{{ required "A valid .Values.externalClickhouse.host is required" .Values.externalClickhouse.host }}
{{- end -}}
{{- end -}}

{{/*
Set ClickHouse port
*/}}
{{- define "sentry.clickhouse.port" -}}
{{- if .Values.clickhouse.enabled -}}
{{- default 9000 .Values.clickhouse.clickhouse.tcp_port }}
{{- else -}}
{{ required "A valid .Values.externalClickhouse.tcpPort is required" .Values.externalClickhouse.tcpPort }}
{{- end -}}
{{- end -}}

{{/*
Set ClickHouse HTTP port
*/}}
{{- define "sentry.clickhouse.http_port" -}}
{{- if .Values.clickhouse.enabled -}}
{{- default 8123 .Values.clickhouse.clickhouse.http_port }}
{{- else -}}
{{ required "A valid .Values.externalClickhouse.httpPort is required" .Values.externalClickhouse.httpPort }}
{{- end -}}
{{- end -}}

{{/*
Set ClickHouse Database
*/}}
{{- define "sentry.clickhouse.database" -}}
{{- if .Values.clickhouse.enabled -}}
default
{{- else -}}
{{ required "A valid .Values.externalClickhouse.database is required" .Values.externalClickhouse.database }}
{{- end -}}
{{- end -}}

{{/*
Set ClickHouse User
*/}}
{{- define "sentry.clickhouse.username" -}}
{{- if .Values.clickhouse.enabled -}}
  {{- if .Values.clickhouse.clickhouse.configmap.users.enabled -}}
{{ (index .Values.clickhouse.clickhouse.configmap.users.user 0).name }}
  {{- else -}}
default
  {{- end -}}
{{- else -}}
{{ required "A valid .Values.externalClickhouse.username is required" .Values.externalClickhouse.username }}
{{- end -}}
{{- end -}}

{{/*
Set ClickHouse Password
*/}}
{{- define "sentry.clickhouse.password" -}}
{{- if .Values.clickhouse.enabled -}}
  {{- if .Values.clickhouse.clickhouse.configmap.users.enabled -}}
{{ (index .Values.clickhouse.clickhouse.configmap.users.user 0).config.password }}
  {{- else -}}
  {{- end -}}
{{- else -}}
{{ .Values.externalClickhouse.password }}
{{- end -}}
{{- end -}}

{{/*
Set ClickHouse cluster name
*/}}
{{- define "sentry.clickhouse.cluster.name" -}}
{{- if .Values.clickhouse.enabled -}}
{{ .Release.Name | printf "%s-clickhouse" }}
{{- else -}}
{{ required "A valid .Values.externalClickhouse.clusterName is required" .Values.externalClickhouse.clusterName }}
{{- end -}}
{{- end -}}

{{/*
Set Kafka Confluent host
*/}}
{{- define "sentry.kafka.host" -}}
{{- if .Values.kafka.enabled -}}
{{- template "sentry.kafka.fullname" . -}}
{{- else if and (.Values.externalKafka) (not (kindIs "slice" .Values.externalKafka)) -}}
{{ required "A valid .Values.externalKafka.host is required" .Values.externalKafka.host }}
{{- end -}}
{{- end -}}

{{/*
Set Kafka Confluent port
*/}}
{{- define "sentry.kafka.port" -}}
{{- if and (.Values.kafka.enabled) (.Values.kafka.service.ports.client) -}}
{{- .Values.kafka.service.ports.client }}
{{- else if and (.Values.externalKafka) (not (kindIs "slice" .Values.externalKafka)) -}}
{{ required "A valid .Values.externalKafka.port is required" .Values.externalKafka.port }}
{{- end -}}
{{- end -}}

{{/*
Set Kafka Confluent Controller port
*/}}
{{- define "sentry.kafka.controller_port" -}}
{{- if and (.Values.kafka.enabled) (.Values.kafka.service.ports.controller ) -}}
{{- .Values.kafka.service.ports.controller }}
{{- else if and (.Values.externalKafka) (not (kindIs "slice" .Values.externalKafka)) -}}
{{ required "A valid .Values.externalKafka.port is required" .Values.externalKafka.port }}
{{- end -}}
{{- end -}}

{{/*
Set Kafka bootstrap servers string
*/}}
{{- define "sentry.kafka.bootstrap_servers_string" -}}
{{- if or (.Values.kafka.enabled) (not (kindIs "slice" .Values.externalKafka)) -}}
{{ printf "%s:%s" (include "sentry.kafka.host" .) (include "sentry.kafka.port" .) }}
{{- else -}}
{{- range $index, $elem := .Values.externalKafka -}}
{{- if $index -}},{{- end -}}{{ printf "%s:%s" $elem.host (toString $elem.port) }}
{{- end -}}
{{- end -}}
{{- end -}}


{{/*
Set RabbitMQ host
*/}}
{{- define "sentry.rabbitmq.host" -}}
{{- if .Values.rabbitmq.enabled -}}
{{- default "sentry-rabbitmq-ha"  (include "sentry.rabbitmq.fullname" .) -}}
{{- else -}}
{{ .Values.rabbitmq.host }}
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
{{- if .Values.externalClickhouse.existingSecret }}
- name: CLICKHOUSE_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.externalClickhouse.existingSecret }}
      key: {{ default "clickhouse-password" .Values.externalClickhouse.existingSecretKey }}
{{- end }}
- name: CLICKHOUSE_MAX_CONNECTIONS
  value: {{ .Values.snuba.clickhouse.maxConnections | quote }}
{{- end -}}

{{- define "vroom.env" -}}
- name: SENTRY_KAFKA_BROKERS_PROFILING
  value: {{ include "sentry.kafka.bootstrap_servers_string" . | quote }}
- name: SENTRY_KAFKA_BROKERS_OCCURRENCES
  value: {{ include "sentry.kafka.bootstrap_servers_string" . | quote }}
- name: SENTRY_BUCKET_PROFILES
  value: file://localhost//var/lib/sentry-profiles
- name: SENTRY_SNUBA_HOST
  value: http://{{ template "sentry.fullname" . }}-snuba:{{ template "snuba.port" . }}
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
      key: {{ default "postgresql-password" .Values.externalPostgresql.existingSecretKey }}
{{- end }}
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
{{- if and (eq .Values.filestore.backend "gcs") .Values.filestore.gcs.secretName }}
- name: GOOGLE_APPLICATION_CREDENTIALS
  value: /var/run/secrets/google/{{ .Values.filestore.gcs.credentialsFile }}
{{- end }}
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
{{- end }}
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
{{- if .Values.openai.existingSecret }}
- name: OPENAI_API_KEY
  valueFrom:
    secretKeyRef:
      name: {{ .Values.openai.existingSecret }}
      key: {{ default "api-token" .Values.openai.existingSecretKey }}
{{- end }}
{{- end -}}

{{- define "sentry.autoscaling.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "autoscaling/v2" -}}
{{- print "autoscaling/v2" -}}
{{- else -}}
{{- print "autoscaling/v1" -}}
{{- end -}}
{{- end -}}
