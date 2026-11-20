{{/*
Taskbroker helpers. Named templates that need chart values must be invoked with
(dict "broker" $broker "root" $root). Do not use $ as chart root inside those
defines — include rebinds $.
*/}}

{{- define "sentry.taskbroker.adapter" -}}
{{- $broker := .broker -}}
{{- $root := .root -}}
{{- $store := default dict $broker.store -}}
{{- $global := default dict $root.Values.sentry.taskBroker.store -}}
{{- $adapter := default "sqlite" $global.adapter -}}
{{- if and (hasKey $store "adapter") (ne (toString $store.adapter) "") -}}
  {{- $adapter = $store.adapter -}}
{{- end -}}
{{- if and (ne $adapter "sqlite") (ne $adapter "postgres") -}}
  {{- fail (printf "sentry.taskBroker store.adapter must be sqlite or postgres, got %q" $adapter) -}}
{{- end -}}
{{- $adapter -}}
{{- end -}}

{{- define "sentry.taskbroker.persist" -}}
{{- $broker := .broker -}}
{{- $root := .root -}}
{{- $enabled := true -}}
{{- $bp := default dict $broker.persistence -}}
{{- $gp := default dict $root.Values.sentry.taskBroker.persistence -}}
{{- if hasKey $bp "enabled" -}}
  {{- $enabled = $bp.enabled -}}
{{- else if hasKey $gp "enabled" -}}
  {{- $enabled = $gp.enabled -}}
{{- end -}}
{{- if $enabled -}}true{{- else -}}false{{- end -}}
{{- end -}}

{{- define "sentry.taskbroker.anyPostgres" -}}
{{- $root := . -}}
{{- $any := false -}}
{{- range $broker := $root.Values.sentry.taskBroker.brokers }}
  {{- if eq (include "sentry.taskbroker.adapter" (dict "broker" $broker "root" $root)) "postgres" -}}
    {{- $any = true -}}
  {{- end }}
{{- end }}
{{- if $any -}}true{{- else -}}false{{- end -}}
{{- end -}}

{{- define "sentry.taskbroker.postgres.host" -}}
{{- $root := .root -}}
{{- $pg := default dict ((default dict $root.Values.sentry.taskBroker.store).postgres) -}}
{{- $host := "" -}}
{{- if and .migrate $pg.migrationHost -}}
  {{- $host = $pg.migrationHost -}}
{{- else if $pg.host -}}
  {{- $host = $pg.host -}}
{{- else if $root.Values.postgresql.enabled -}}
  {{- $host = include "sentry.postgresql.host" $root -}}
{{- else -}}
  {{- fail "sentry.taskBroker.store.postgres.host is required when using the postgres adapter with postgresql.enabled=false. Use the PostgreSQL primary, or a transaction-mode pooler together with store.postgres.migrationHost for the migrate Job." -}}
{{- end -}}
{{- $pgbouncer := printf "%s-pgbouncer" (include "sentry.fullname" $root) -}}
{{- if eq $host $pgbouncer -}}
  {{- fail "sentry.taskBroker.store.postgres.host and migrationHost must not be the chart PgBouncer Service, which only serves the Sentry database." -}}
{{- end -}}
{{- $host -}}
{{- end -}}

{{- define "sentry.taskbroker.postgres.port" -}}
{{- $root := .root -}}
{{- $pg := default dict ((default dict $root.Values.sentry.taskBroker.store).postgres) -}}
{{- if and .migrate $pg.migrationPort -}}
  {{- $pg.migrationPort -}}
{{- else if or (not (hasKey $pg "port")) (eq (toString $pg.port) "") -}}
  {{- if $root.Values.postgresql.enabled -}}
    {{- include "sentry.postgresql.port" $root -}}
  {{- else -}}
    5432
  {{- end -}}
{{- else -}}
  {{- $pg.port -}}
{{- end -}}
{{- end -}}

{{- define "sentry.taskbroker.postgres.user" -}}
{{- $root := .root -}}
{{- $pg := default dict ((default dict $root.Values.sentry.taskBroker.store).postgres) -}}
{{- if and (hasKey $pg "user") (ne (toString $pg.user) "") -}}
  {{- $pg.user -}}
{{- else -}}
  {{- include "sentry.postgresql.username" $root -}}
{{- end -}}
{{- end -}}

{{- define "sentry.taskbroker.postgres.ddlUser" -}}
{{- $root := .root -}}
{{- $pg := default dict ((default dict $root.Values.sentry.taskBroker.store).postgres) -}}
{{- if $pg.ddlUser -}}
  {{- $pg.ddlUser -}}
{{- else -}}
  {{- include "sentry.taskbroker.postgres.user" . -}}
{{- end -}}
{{- end -}}

{{- define "sentry.taskbroker.postgres.database" -}}
{{- $pg := default dict ((default dict .root.Values.sentry.taskBroker.store).postgres) -}}
{{- default "taskbroker" $pg.database -}}
{{- end -}}

{{- define "sentry.taskbroker.postgres.defaultDatabase" -}}
{{- $root := .root -}}
{{- $pg := default dict ((default dict $root.Values.sentry.taskBroker.store).postgres) -}}
{{- if $pg.defaultDatabase -}}
  {{- $pg.defaultDatabase -}}
{{- else -}}
  {{- include "sentry.postgresql.database" $root -}}
{{- end -}}
{{- end -}}

{{/*
Password env for postgres brokers. Never emit passwords in config.yml (PgConfig
defaults password to "password").
*/}}
{{- define "sentry.taskbroker.postgres.env" -}}
{{- $root := .root -}}
{{- $pg := default dict ((default dict $root.Values.sentry.taskBroker.store).postgres) -}}
{{- $secret := default "" $pg.existingSecret -}}
{{- $key := default "postgresql-password" $pg.existingSecretKey -}}
{{- $ddlSecret := $secret -}}
{{- $ddlKey := $key -}}
{{- if $pg.ddlExistingSecret -}}
  {{- $ddlSecret = $pg.ddlExistingSecret -}}
  {{- $ddlKey = default "postgresql-password" $pg.ddlExistingSecretKey -}}
{{- end }}
{{- if $pg.password }}
- name: TASKBROKER_STORE__PG__PASSWORD
  value: {{ $pg.password | quote }}
{{- else if $secret }}
- name: TASKBROKER_STORE__PG__PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ $secret }}
      key: {{ $key | quote }}
{{- else if $root.Values.postgresql.enabled }}
- name: TASKBROKER_STORE__PG__PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ default (include "sentry.postgresql.fullname" $root) $root.Values.postgresql.auth.existingSecret }}
      key: {{ default "postgres-password" $root.Values.postgresql.auth.secretKeys.adminPasswordKey | quote }}
{{- else }}
{{- fail "sentry.taskBroker.store.postgres.password or existingSecret is required when using the postgres adapter" }}
{{- end }}
{{- if $pg.ddlExistingSecret }}
- name: TASKBROKER_STORE__PG__DDL_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ $ddlSecret }}
      key: {{ $ddlKey | quote }}
{{- else if $pg.password }}
- name: TASKBROKER_STORE__PG__DDL_PASSWORD
  value: {{ $pg.password | quote }}
{{- else if $secret }}
- name: TASKBROKER_STORE__PG__DDL_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ $secret }}
      key: {{ $ddlKey | quote }}
{{- else if $root.Values.postgresql.enabled }}
- name: TASKBROKER_STORE__PG__DDL_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ default (include "sentry.postgresql.fullname" $root) $root.Values.postgresql.auth.existingSecret }}
      key: {{ default "postgres-password" $root.Values.postgresql.auth.secretKeys.adminPasswordKey | quote }}
{{- end }}
{{- end -}}

{{/*
Render taskbroker config.yml for a single broker.
Expected keys on broker: kafkaDeadletterTopic, kafkaRetryTopic, kafkaTopics.
Optional: kafkaSessionTimeoutMs (defaults to 60000).
Invoke as: include "sentry.taskbroker.configYml" (dict "broker" $broker "root" $root)
The migrate Job adds "migrate" true, so migrationHost / migrationPort / migrationQueryParams apply.
*/}}
{{- define "sentry.taskbroker.configYml" -}}
{{- $broker := .broker -}}
{{- $root := .root -}}
{{- $adapter := include "sentry.taskbroker.adapter" . -}}
kafka_session_timeout_ms: {{ default 60000 $broker.kafkaSessionTimeoutMs }}
kafka_deadletter_topic: {{ required (printf "sentry.taskBroker.brokers[%s].kafkaDeadletterTopic is required" $broker.name) $broker.kafkaDeadletterTopic }}
kafka_retry_topic: {{ required (printf "sentry.taskBroker.brokers[%s].kafkaRetryTopic is required" $broker.name) $broker.kafkaRetryTopic }}

{{- if $root.Values.ipv6 }}
grpc_addr: '[::]'
{{- end }}

kafka_topics:
{{- range $topicName, $topic := $broker.kafkaTopics }}
  {{ $topicName }}:
    cluster: {{ required (printf "kafkaTopics.%s.cluster is required" $topicName) $topic.cluster }}
    consumer_group: {{ required (printf "kafkaTopics.%s.consumerGroup is required" $topicName) $topic.consumerGroup }}
    {{- if $topic.produceOnly }}
    produce_only: true
    {{- end }}
    {{- if $topic.raw }}
    raw:
      namespace: {{ required (printf "kafkaTopics.%s.raw.namespace is required" $topicName) $topic.raw.namespace }}
      application: {{ required (printf "kafkaTopics.%s.raw.application is required" $topicName) $topic.raw.application }}
      taskname: {{ required (printf "kafkaTopics.%s.raw.taskname is required" $topicName) $topic.raw.taskname }}
      processing_deadline_duration: {{ default 60 $topic.raw.processingDeadlineDuration }}
    {{- end }}
{{- end }}
{{- if eq $adapter "postgres" }}
{{- $pg := default dict ((default dict $root.Values.sentry.taskBroker.store).postgres) }}
{{- $queryParams := $pg.queryParams }}
{{- if and .migrate $pg.migrationQueryParams }}
{{- $queryParams = $pg.migrationQueryParams }}
{{- end }}

store:
  adapter: postgres
  pg:
    run_migrations: false
    host: {{ include "sentry.taskbroker.postgres.host" . }}
    port: {{ include "sentry.taskbroker.postgres.port" . }}
    username: {{ include "sentry.taskbroker.postgres.user" . }}
    ddl_username: {{ include "sentry.taskbroker.postgres.ddlUser" . }}
    database_name: {{ include "sentry.taskbroker.postgres.database" . }}
    default_database_name: {{ include "sentry.taskbroker.postgres.defaultDatabase" . }}
    {{- if $queryParams }}
    query_params: {{ $queryParams | quote }}
    {{- end }}
{{- end }}
{{- end -}}
