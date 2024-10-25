{{- define "sentry.relay.config" -}}
{{- $redisHost := include "sentry.redis.host" . -}}
{{- $redisPort := include "sentry.redis.port" . -}}
{{- $redisPass := include "sentry.redis.password" . -}}
{{- $redisDb     := include "sentry.redis.db" . -}}
{{- $redisProto  := ternary "rediss" "redis" (eq (include "sentry.redis.ssl" .) "true")  -}}
config.yml: |-
  relay:
    {{- if .Values.relay.mode }}
    mode: {{ .Values.relay.mode }}
    {{- end }}
    upstream: "http://{{ template "sentry.fullname" . }}-web:{{ .Values.service.externalPort }}/"
    {{- if .Values.ipv6 }}
    host: "::"
    {{- else }}
    host: 0.0.0.0
    {{- end }}
    port: {{ template "relay.port" }}

    {{- if .Values.relay.cache }}
    {{- if .Values.relay.cache.envelopeBufferSize }}
    cache:
      envelope_buffer_size: {{ int64 .Values.relay.cache.envelopeBufferSize | quote }}
    {{- end }}
    {{- end }}

    {{- if .Values.relay.logging }}
    logging:
      {{- if .Values.relay.logging.level }}
      level: {{ .Values.relay.logging.level }}
      {{- end }}
      {{- if .Values.relay.logging.format }}
      format: {{ .Values.relay.logging.format }}
      {{- end }}
    {{- end }}

  processing:
    enabled: true
    {{- if .Values.geodata.path }}
    geoip_path: {{ .Values.geodata.path | quote }}
    {{- end }}

    kafka_config:
      - name: "bootstrap.servers"
        value: {{ (include "sentry.kafka.bootstrap_servers_string" .) | quote }}
      {{- if .Values.relay.processing.kafkaConfig.messageMaxBytes }}
      - name: "message.max.bytes"
        value: {{ int64 .Values.relay.processing.kafkaConfig.messageMaxBytes | quote }}
      {{- end }}
      {{- if .Values.relay.processing.kafkaConfig.messageTimeoutMs }}
      - name: "message.timeout.ms"
        value: {{ int64 .Values.relay.processing.kafkaConfig.messageTimeoutMs | quote }}
      {{- end }}
      {{- if .Values.relay.processing.kafkaConfig.requestTimeoutMs }}
      - name: "request.timeout.ms"
        value: {{ int64 .Values.relay.processing.kafkaConfig.requestTimeoutMs | quote }}
      {{- end }}
      {{- if .Values.relay.processing.kafkaConfig.deliveryTimeoutMs }}
      - name: "delivery.timeout.ms"
        value: {{ int64 .Values.relay.processing.kafkaConfig.deliveryTimeoutMs | quote }}
      {{- end }}
      {{- if .Values.relay.processing.kafkaConfig.apiVersionRequestTimeoutMs }}
      - name: "api.version.request.timeout.ms"
        value: {{ int64 .Values.relay.processing.kafkaConfig.apiVersionRequestTimeoutMs | quote }}
      {{- end }}
      {{- $sentryKafkaSaslMechanism := include "sentry.kafka.sasl_mechanism" . -}}
      {{- if not (eq "None" $sentryKafkaSaslMechanism) }}
      - name: "sasl.mechanism"
        value: {{ $sentryKafkaSaslMechanism | quote }}
      {{- end }}
      {{- $sentryKafkaSaslUsername := include "sentry.kafka.sasl_username" . -}}
      {{- if not (eq "None" $sentryKafkaSaslUsername) }}
      - name: "sasl.username"
        value: {{ $sentryKafkaSaslUsername | quote }}
      {{- end }}
      {{- $sentryKafkaSaslPassword := include "sentry.kafka.sasl_password" . -}}
      {{- if not (eq "None" $sentryKafkaSaslPassword) }}
      - name: "sasl.password"
        value: {{ $sentryKafkaSaslPassword | quote }}
      {{- end }}
      {{- $sentryKafkaSecurityProtocol := include "sentry.kafka.security_protocol" . -}}
      {{- if not (eq "plaintext" $sentryKafkaSecurityProtocol) }}
      - name: security.protocol
        value: {{ $sentryKafkaSecurityProtocol | quote }}
      {{- end }}
  {{- if .Values.relay.processing.additionalKafkaConfig }}
  {{ toYaml .Values.relay.processing.additionalKafkaConfig | nindent 6 }}
  {{- end }}

    {{- if $redisPass }}
    {{- if and (not .Values.externalRedis.existingSecret) (not .Values.redis.auth.existingSecret)}}
    redis: "{{ $redisProto }}://:{{ $redisPass }}@{{ $redisHost }}:{{ $redisPort }}/{{ $redisDb }}"
    {{- end }}
    {{- else }}
    redis: "{{ $redisProto }}://{{ $redisHost }}:{{ $redisPort }}/{{ $redisDb }}"
    {{- end }}

    {{- if ((.Values.kafkaTopicOverrides).prefix) }}
    topics:
      metrics_sessions: "{{ default "" .Values.kafkaTopicOverrides.prefix }}ingest-metrics"
      events: "{{ default "" .Values.kafkaTopicOverrides.prefix }}ingest-attachments"
      transactions: "{{ default "" .Values.kafkaTopicOverrides.prefix }}ingest-transactions"
      outcomes: "{{ default "" .Values.kafkaTopicOverrides.prefix }}outcomes"
      outcomes_billing: "{{ default "" .Values.kafkaTopicOverrides.prefix }}ingest-outcomes"
      metrics_generic: "{{ default "" .Values.kafkaTopicOverrides.prefix }}ingest-performance-metrics"
      profiles: "{{ default "" .Values.kafkaTopicOverrides.prefix }}profiles"
      replay_events: "{{ default "" .Values.kafkaTopicOverrides.prefix }}ingest-replay-events"
      replay_recordings: "{{ default "" .Values.kafkaTopicOverrides.prefix }}ingest-replay-recordings"
      monitors: "{{ default "" .Values.kafkaTopicOverrides.prefix }}ingest-monitors"
      spans: "{{ default "" .Values.kafkaTopicOverrides.prefix }}snuba-spans"
      metrics_summaries: "{{ default "" .Values.kafkaTopicOverrides.prefix }}snuba-metrics-summaries"
      cogs: "{{ default "" .Values.kafkaTopicOverrides.prefix }}shared-resources-usage"
      feedback: "{{ default "" .Values.kafkaTopicOverrides.prefix }}ingest-feedback-events"
    {{- else }}
    topics:
      metrics_sessions: "ingest-metrics"
    {{- end }}

  {{ .Values.config.relay | nindent 2 }}
{{- end -}}
