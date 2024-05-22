{{- define "sentry.relay.config" -}}
{{- $redisHost := include "sentry.redis.host" . -}}
{{- $redisPort := include "sentry.redis.port" . -}}
{{- $redisPass := include "sentry.redis.password" . -}}
config.yml: |-
  relay:
    {{- if .Values.relay.mode }}
    mode: {{ .Values.relay.mode }}
    {{- end }}
    upstream: "http://{{ template "sentry.fullname" . }}-web:{{ .Values.service.externalPort }}/"
    host: 0.0.0.0
    port: {{ template "relay.port" }}

  processing:
    enabled: true
    {{- if .Values.geodata.path }}
    geoip_path: {{ .Values.geodata.path | quote }}
    {{- end }}

    kafka_config:
      - name: "bootstrap.servers"
        value: {{ (include "sentry.kafka.bootstrap_servers_string" .) | quote }}
      - name: "message.max.bytes"
        value: 50000000  # 50MB or bust

    {{- if $redisPass }}
    redis: "redis://:{{ $redisPass }}@{{ $redisHost }}:{{ $redisPort }}"
    {{- else }}
    redis: "redis://{{ $redisHost }}:{{ $redisPort }}"
    {{- end }}
    topics:
      metrics_transactions: ingest-performance-metrics
      metrics_sessions: ingest-metrics

  {{ .Values.config.relay | nindent 2 }}
{{- end -}}
