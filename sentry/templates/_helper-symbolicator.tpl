{{- define "sentry.symbolicator.config" -}}
config.yml: {{ toYaml .Values.symbolicator.api.config | indent 2 }}
{{- end -}}
