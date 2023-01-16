{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "clickhouse.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "clickhouse.fullname" -}}
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
Create chart name and version as used by the chart label.
*/}}
{{- define "clickhouse.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create clickhouse path. 
if .Values.clickhouse.path is empty, default value "/var/lib/clickhouse".
*/}}
{{- define "clickhouse.fullpath" -}}
{{- if .Values.clickhouse.path -}}
{{- .Values.clickhouse.path | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s" "/var/lib/clickhouse" -}}
{{- end -}}
{{- end -}}

{{/*
Create clickhouse log path.
if .Values.clickhouse.configmap.logger.path is empty, default value "/var/log/clickhouse-server".
*/}}
{{- define "clickhouse.logpath" -}}
{{- if .Values.clickhouse.configmap.logger.path -}}
{{- .Values.clickhouse.configmap.logger.path | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s" "/var/log/clickhouse-server" -}}
{{- end -}}
{{- end -}}


{{/*
Returns available value for certain key in an existing secret (if it exists).
*/}}
{{- define "getValueFromSecret" }}
	{{- $obj := (lookup "v1" "Secret" .Namespace .Name).data -}}
	{{- if and ($obj) (hasKey $obj .Key) }}
		{{- index $obj .Key | b64dec -}}
	{{- end -}}
{{- end -}}

{{/*
Take list of users from .Values.clickhouse.configmap.users.user and replace/add username and password/password_sha256_hex from existingSecret (if specified)
Save the result into to clickhouse.users (used in configmap-users.yaml)
*/}}
{{- define "clickhouse.users" -}}
	{{ $result := list }}
	{{ $namespace := .Release.Namespace }}
	{{ range $user := .Values.clickhouse.configmap.users.user }}
		{{ $modifiedUser := mustDeepCopy $user }}
		{{ if hasKey $user "existingSecret" }}
			{{ if hasKey $user "existingSecretNameKey" }}
				{{ $username := (include "getValueFromSecret" (dict "Namespace" $namespace "Name" $user.existingSecret "Key" $user.existingSecretNameKey))  }}
				{{- if $username }}
					{{ $_ := set $modifiedUser "name" $username }}
				{{- else -}}
					{{- $errorMessage := printf "given existingSecret '%s' or its existingSecretNameKey '%s' cannot be loaded" $user.existingSecret $user.existingSecretNameKey }}
					{{- fail $errorMessage -}}
				{{- end -}}
			{{- end -}}

			{{ $usersConfig := mustDeepCopy (default (dict) ($user.config)) }}
			{{ if hasKey $user "existingSecretPasswordSHA256Key" }}
				{{ $passwordSHA256 := (include "getValueFromSecret" (dict "Namespace" $namespace "Name" $user.existingSecret "Key" $user.existingSecretPasswordSHA256Key))  }}
				{{- if $passwordSHA256 }}
					{{ $_ := set $usersConfig "password_sha256_hex" $passwordSHA256 }}
					{{ $_ := unset $usersConfig "password"}}
				{{- else -}}
					{{- $errorMessage := printf "given existingSecret '%s' or its existingSecretPasswordSHA256Key '%s' cannot be loaded" $user.existingSecret $user.existingSecretPasswordSHA256Key }}
					{{- fail $errorMessage -}}
				{{- end -}}
			{{- end -}}
			{{ if hasKey $user "existingSecretPasswordKey" }}
				{{ $password := (include "getValueFromSecret" (dict "Namespace" $namespace "Name" $user.existingSecret "Key" $user.existingSecretPasswordKey))  }}
				{{- if $password }}
					{{ $_ := set $usersConfig "password_sha256_hex" (sha256sum $password) }}
					{{ $_ := unset $usersConfig "password"}}
				{{- else -}}
					{{- $errorMessage := printf "given existingSecret '%s' or its existingSecretPasswordKey '%s' cannot be loaded" $user.existingSecret $user.existingSecretPasswordKey }}
					{{- fail $errorMessage -}}
				{{- end -}}
			{{- end -}}
			{{- if gt (len $usersConfig) 0 -}}
				{{ $_ := set $modifiedUser "config" $usersConfig }}
			{{- end -}}
		{{- end -}}
		{{ $result = mustAppend $result $modifiedUser }}
	{{- end }}
	{{ toJson $result }}
{{- end }}
