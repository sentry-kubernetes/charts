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

    {{- if and ($redisPass) (not .Values.externalRedis.existingSecret) }}
    redis: "{{ $redisProto }}://{{ $redisPass }}@{{ $redisHost }}:{{ $redisPort }}/{{ $redisDb }}"
    {{- else }}
    redis: "{{ $redisProto }}://{{ $redisPass }}@{{ $redisHost }}:{{ $redisPort }}/{{ $redisDb }}"
    {{- end }}
    topics:
      metrics_sessions: ingest-metrics

  {{ .Values.config.relay | nindent 2 }}
{{- end -}}
