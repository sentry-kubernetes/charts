{{- define "sentry.prefix" -}}
    {{- if .Values.prefix -}}
        {{.Values.prefix}}-
    {{- else -}}
    {{- end -}}
{{- end -}}

{{- define "sentry.port" -}}9000{{- end -}}
{{- define "snuba.port" -}}1218{{- end -}}

{{/* vim: set filetype=mustache: */}}
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
{{- .Values.postgresql.postgresqlHost -}}
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
    "5432"
{{- else -}}
{{- default "5432" .Values.postgresql.postgresqlPort | quote -}}
{{- end -}}
{{- end -}}

{{/*
Set redis host
*/}}
{{- define "sentry.redis.host" -}}
{{- if .Values.redis.enabled -}}
    {{- if .Values.redis.hostOverride -}}
        {{- .Values.redis.hostOverride -}}
    {{- else -}}
        {{- template "sentry.redis.fullname" . -}}-master
    {{- end -}}
{{- else -}}
    {{- .Values.redis.host -}}
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
    6379
{{- else -}}
{{- default 6379 .Values.redis.port -}}
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
Set Clickhouse host
*/}}
{{- define "sentry.clickhouse.host" -}}
    {{- default "clickhouse" (include "sentry.clickhouse.fullname" .) -}}
{{- end -}}

{{/*
Set Clickhouse port
*/}}
{{- define "sentry.clickhouse.port" -}}
    {{- default 9000 .Values.clickhouse.clickhouse.tcp_port }}
{{- end -}}

{{/*
Set Kafka Confluent host
*/}}
{{- define "sentry.kafka.host" -}}
{{- if .Values.kafka.enabled -}}
    {{- template "sentry.kafka.fullname" . -}}
{{- else -}}
    kafka-confluent
{{- end -}}
{{- end -}}

{{/*
Set Kafka Confluent port
*/}}
{{- define "sentry.kafka.port" -}}
{{- if and (.Values.kafka.enabled) (.Values.kafka.service.port) -}}
    {{- .Values.kafka.service.port }}
{{- else -}}
    9092
{{- end -}}
{{- end -}}


{{/*
Set Zookeeper host
*/}}
{{- define "sentry.kafka.zookeeper.host" -}}
{{- if .Values.kafka.zookeeper.enabled -}}
    {{- template "sentry.kafka.zookeeper.fullname" . -}}
{{- else -}}
    "zookeeper"
{{- end -}}
{{- end -}}

{{/*
Set Zookeeper port
*/}}
{{- define "sentry.kafka.zookeeper.port" -}}
{{- if .Values.kafka.zookeeper.enabled -}}
    {{- default "2181" .Values.kafka.zookeeper.service.port }}
{{- else -}}
    "2181"
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

