{{- define "sentry.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{- define "sentry.prefix" -}}
    {{- if .Values.prefix -}}
        {{.Values.prefix}}-
    {{- else -}}
    {{- end -}}
{{- end -}}

{{- define "sentry.port" -}}9000{{- end -}}
{{- define "snuba.port" -}}1218{{- end -}}

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

{{- define "broker.url" -}}
    {{- if .Values.rabbitmq.enabled -}}
    amqp://{{ .Values.rabbitmq.username }}:{{ .Values.rabbitmq.password }}@{{ .Values.rabbitmq.host }}:5672//
    {{- else if .Values.redis.password -}}
    redis://:{{ .Values.redis.password }}@{{ .Values.redis.host }}:6379/0
    {{- else -}}
    redis://{{ .Values.redis.host }}:6379/0
    {{- end -}}
{{- end -}}

{{- define "redis.password.fromSecret" -}}
{{- if and .Values.redis.existingPasswordSecret .Values.redis.existingPasswordSecretKey }}
        - name: REDIS_PASSWORD
          valueFrom:
            secretKeyRef:
              key: {{ .Values.redis.existingPasswordSecret }}
              name: {{ .Values.redis.existingPasswordSecretKey }}
              optional: false
{{- end }}
{{- end -}}