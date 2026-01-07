# Add this to templates/_helpers.tpl if not already present

{{/*
Relay port
*/}}
{{- define "relay.port" -}}
{{- default 3000 .Values.relay.service.port -}}
{{- end -}}
