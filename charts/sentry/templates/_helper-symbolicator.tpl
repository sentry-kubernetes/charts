{{- define "sentry.symbolicator.config" -}}
config.yml: {{ toYaml .Values.symbolicator.api.config }}
{{- end -}}
