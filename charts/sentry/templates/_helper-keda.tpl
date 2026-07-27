{{/* Select the chart-managed autoscaler for a workload. */}}
{{- define "sentry.autoscaling.validate" -}}
{{- $autoscaling := default dict .autoscaling -}}
{{- $valuePath := default "workload" .valuePath -}}
{{- if $autoscaling.enabled -}}
{{- $autoscaler := default "hpa" $autoscaling.autoscaler -}}
{{- if not (has $autoscaler (list "hpa" "keda")) -}}
{{- fail (printf "%s.autoscaling.autoscaler must be one of: hpa, keda (got %q)" $valuePath $autoscaler) -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "sentry.autoscaling.isHpa" -}}
{{- $autoscaling := default dict .autoscaling -}}
{{- include "sentry.autoscaling.validate" . -}}
{{- if and $autoscaling.enabled (eq (default "hpa" $autoscaling.autoscaler) "hpa") -}}true{{- end -}}
{{- end -}}

{{- define "sentry.autoscaling.isKeda" -}}
{{- $autoscaling := default dict .autoscaling -}}
{{- include "sentry.autoscaling.validate" . -}}
{{- if and $autoscaling.enabled (eq (default "hpa" $autoscaling.autoscaler) "keda") -}}true{{- end -}}
{{- end -}}

{{/* Hook annotations shared by ScaledObjects whose target is a hook workload. */}}
{{- define "sentry.keda.annotations" -}}
meta.helm.sh/release-name: {{ .Release.Name | quote }}
meta.helm.sh/release-namespace: {{ .Release.Namespace | quote }}
"helm.sh/hook": "post-install,post-upgrade"
"helm.sh/hook-weight": "25"
"helm.sh/hook-delete-policy": "before-hook-creation"
{{- end -}}

{{/* Build a PromQL query for consumer-group lag exported by kafka_exporter. */}}
{{- define "sentry.keda.kafkaExporterLagQuery" -}}
{{- $metricName := default "kafka_consumergroup_lag" .metricName -}}
{{- printf "sum(%s{topic=%q,consumergroup=%q})" $metricName .topic .consumerGroup -}}
{{- end -}}

{{/* Render a KEDA ScaledObject for a Deployment-backed workload. */}}
{{- define "sentry.autoscaling.scaledObject" -}}
{{- $root := .root -}}
{{- $autoscaling := default dict .autoscaling -}}
{{- $globalAutoscaling := default dict $root.Values.global.autoscaling -}}
{{- $globalTriggers := default dict $globalAutoscaling.triggers -}}
{{- $triggers := default dict $autoscaling.triggers -}}
{{- $kafka := mergeOverwrite (deepCopy (default dict $globalTriggers.kafka)) (deepCopy (default dict $triggers.kafka)) -}}
{{- $kafkaLag := mergeOverwrite (deepCopy (default dict $globalTriggers.kafkaLag)) (deepCopy (default dict $triggers.kafkaLag)) -}}
{{- $prometheus := mergeOverwrite (deepCopy (default dict $globalTriggers.prometheus)) (deepCopy (default dict $triggers.prometheus)) -}}
{{- $cpu := default dict $triggers.cpu -}}
{{- $memory := default dict $triggers.memory -}}
{{- $cpuFallback := and (not $kafka.enabled) (not $kafkaLag.enabled) (not $prometheus.enabled) (not (hasKey $triggers "cpu")) $autoscaling.targetCPUUtilizationPercentage -}}
{{- $memoryFallback := and (not $kafka.enabled) (not $kafkaLag.enabled) (not $prometheus.enabled) (not (hasKey $triggers "memory")) $autoscaling.targetMemoryUtilizationPercentage -}}
{{- $cpuEnabled := or $cpu.enabled $cpuFallback -}}
{{- $memoryEnabled := or $memory.enabled $memoryFallback -}}
{{- if not (or $kafka.enabled $kafkaLag.enabled $prometheus.enabled $cpuEnabled $memoryEnabled) -}}
{{- fail (printf "%s.autoscaling must enable at least one KEDA trigger" .valuePath) -}}
{{- end -}}
{{- $minReplicas := 1 -}}
{{- if hasKey $autoscaling "minReplicas" -}}
{{- $minReplicas = $autoscaling.minReplicas -}}
{{- end -}}
{{- $maxReplicas := 3 -}}
{{- if hasKey $autoscaling "maxReplicas" -}}
{{- $maxReplicas = $autoscaling.maxReplicas -}}
{{- end -}}
{{- $pollingInterval := 30 -}}
{{- if hasKey $globalAutoscaling "pollingInterval" -}}
{{- $pollingInterval = $globalAutoscaling.pollingInterval -}}
{{- end -}}
{{- if hasKey $autoscaling "pollingInterval" -}}
{{- $pollingInterval = $autoscaling.pollingInterval -}}
{{- end -}}
{{- $cooldownPeriod := 300 -}}
{{- if hasKey $globalAutoscaling "cooldownPeriod" -}}
{{- $cooldownPeriod = $globalAutoscaling.cooldownPeriod -}}
{{- end -}}
{{- if hasKey $autoscaling "cooldownPeriod" -}}
{{- $cooldownPeriod = $autoscaling.cooldownPeriod -}}
{{- end -}}
{{- if not (regexMatch "^[0-9]+$" (toString $minReplicas)) -}}
{{- fail (printf "%s.autoscaling.minReplicas must be a non-negative integer" .valuePath) -}}
{{- end -}}
{{- if not (regexMatch "^[0-9]+$" (toString $maxReplicas)) -}}
{{- fail (printf "%s.autoscaling.maxReplicas must be a positive integer" .valuePath) -}}
{{- end -}}
{{- if lt (int $maxReplicas) 1 -}}
{{- fail (printf "%s.autoscaling.maxReplicas must be at least 1" .valuePath) -}}
{{- end -}}
{{- if gt (int $minReplicas) (int $maxReplicas) -}}
{{- fail (printf "%s.autoscaling.minReplicas must not exceed maxReplicas" .valuePath) -}}
{{- end -}}
{{- if not (regexMatch "^[0-9]+$" (toString $pollingInterval)) -}}
{{- fail (printf "%s.autoscaling.pollingInterval must be a positive integer" .valuePath) -}}
{{- end -}}
{{- if lt (int $pollingInterval) 1 -}}
{{- fail (printf "%s.autoscaling.pollingInterval must be at least 1" .valuePath) -}}
{{- end -}}
{{- if not (regexMatch "^[0-9]+$" (toString $cooldownPeriod)) -}}
{{- fail (printf "%s.autoscaling.cooldownPeriod must be a non-negative integer" .valuePath) -}}
{{- end -}}
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: {{ template "sentry.fullname" $root }}-{{ default .name .scaledObjectName }}
  {{- if .hook }}
  annotations:
{{ include "sentry.keda.annotations" $root | indent 4 }}
  {{- end }}
  labels:
    {{- include "sentry.component.labels" (dict "component" .component "ctx" $root) | nindent 4 }}
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: {{ template "sentry.fullname" $root }}-{{ .targetName }}
  pollingInterval: {{ $pollingInterval }}
  cooldownPeriod: {{ $cooldownPeriod }}
  minReplicaCount: {{ $minReplicas }}
  maxReplicaCount: {{ $maxReplicas }}
  {{- with $autoscaling.advanced }}
  advanced:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  triggers:
    {{- if $kafkaLag.enabled }}
    - type: prometheus
      metadata:
        serverAddress: {{ required (printf "%s.autoscaling.triggers.kafkaLag.serverAddress is required" .valuePath) $kafkaLag.serverAddress | quote }}
        query: {{ include "sentry.keda.kafkaExporterLagQuery" (dict "metricName" $kafkaLag.metricName "topic" (required (printf "%s.autoscaling.triggers.kafkaLag.topic is required" .valuePath) (default .kafkaTopic $kafkaLag.topic)) "consumerGroup" (required (printf "%s.autoscaling.triggers.kafkaLag.consumerGroup is required" .valuePath) (default .kafkaConsumerGroup $kafkaLag.consumerGroup))) | quote }}
        threshold: {{ default "1000" $kafkaLag.threshold | quote }}
        activationThreshold: {{ default "0" $kafkaLag.activationThreshold | quote }}
        {{- with $kafkaLag.namespace }}
        namespace: {{ . | quote }}
        {{- end }}
        {{- with $kafkaLag.customHeaders }}
        customHeaders: {{ . | quote }}
        {{- end }}
        {{- if hasKey $kafkaLag "ignoreNullValues" }}
        ignoreNullValues: {{ get $kafkaLag "ignoreNullValues" | quote }}
        {{- end }}
        {{- if hasKey $kafkaLag "unsafeSsl" }}
        unsafeSsl: {{ get $kafkaLag "unsafeSsl" | quote }}
        {{- end }}
      {{- with $kafkaLag.authenticationRef }}
      authenticationRef:
        name: {{ . | quote }}
      {{- end }}
    {{- end }}
    {{- if $prometheus.enabled }}
    - type: prometheus
      metadata:
        serverAddress: {{ required (printf "%s.autoscaling.triggers.prometheus.serverAddress is required" .valuePath) $prometheus.serverAddress | quote }}
        query: {{ required (printf "%s.autoscaling.triggers.prometheus.query is required" .valuePath) $prometheus.query | quote }}
        threshold: {{ default "100" $prometheus.threshold | quote }}
        {{- with $prometheus.activationThreshold }}
        activationThreshold: {{ . | quote }}
        {{- end }}
        {{- with $prometheus.namespace }}
        namespace: {{ . | quote }}
        {{- end }}
        {{- with $prometheus.customHeaders }}
        customHeaders: {{ . | quote }}
        {{- end }}
        {{- if hasKey $prometheus "ignoreNullValues" }}
        ignoreNullValues: {{ get $prometheus "ignoreNullValues" | quote }}
        {{- end }}
        {{- with $prometheus.queryParameters }}
        queryParameters: {{ . | quote }}
        {{- end }}
        {{- if hasKey $prometheus "unsafeSsl" }}
        unsafeSsl: {{ get $prometheus "unsafeSsl" | quote }}
        {{- end }}
      {{- with $prometheus.authenticationRef }}
      authenticationRef:
        name: {{ . | quote }}
      {{- end }}
    {{- end }}
    {{- if $kafka.enabled }}
    - type: kafka
      metadata:
        bootstrapServers: {{ default (include "sentry.kafka.bootstrap_servers_string" $root) $kafka.bootstrapServers | quote }}
        topic: {{ required (printf "%s.autoscaling.triggers.kafka.topic is required" .valuePath) (default .kafkaTopic $kafka.topic) | quote }}
        consumerGroup: {{ required (printf "%s.autoscaling.triggers.kafka.consumerGroup is required" .valuePath) (default .kafkaConsumerGroup $kafka.consumerGroup) | quote }}
        lagThreshold: {{ default "1000" $kafka.lagThreshold | quote }}
        activationLagThreshold: {{ default "0" $kafka.activationLagThreshold | quote }}
        offsetResetPolicy: {{ default "latest" $kafka.offsetResetPolicy | quote }}
        {{- range $key := list "allowIdleConsumers" "scaleToZeroOnInvalidOffset" "excludePersistentLag" "limitToPartitionsWithLag" "version" "partitionLimitation" "sasl" "tls" "unsafeSsl" }}
        {{- if hasKey $kafka $key }}
        {{ $key }}: {{ get $kafka $key | quote }}
        {{- end }}
        {{- end }}
      {{- with $kafka.authenticationRef }}
      authenticationRef:
        name: {{ . | quote }}
      {{- end }}
    {{- end }}
    {{- if $cpuEnabled }}
    - type: cpu
      metricType: Utilization
      metadata:
        value: {{ default $autoscaling.targetCPUUtilizationPercentage $cpu.value | quote }}
    {{- end }}
    {{- if $memoryEnabled }}
    - type: memory
      metricType: Utilization
      metadata:
        value: {{ default $autoscaling.targetMemoryUtilizationPercentage $memory.value | quote }}
    {{- end }}
{{- end -}}

{{/* Place a ScaledObject next to its owning Deployment. */}}
{{- define "sentry.autoscaling.forDeployment" -}}
{{- if and .enabled (include "sentry.autoscaling.isKeda" (dict "autoscaling" .values.autoscaling "valuePath" .valuePath)) }}
---
{{ include "sentry.autoscaling.scaledObject" (dict "root" .root "autoscaling" .values.autoscaling "name" .name "scaledObjectName" .scaledObjectName "targetName" .targetName "component" .component "valuePath" .valuePath "kafkaTopic" .kafkaTopic "kafkaConsumerGroup" .kafkaConsumerGroup "hook" .hook) }}
{{- end }}
{{- end -}}
