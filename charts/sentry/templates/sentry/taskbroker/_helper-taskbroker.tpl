{{/*
Render taskbroker config.yml for a single broker.
Expected keys on broker: kafkaDeadletterTopic, kafkaRetryTopic, kafkaTopics.
*/}}
{{- define "sentry.taskbroker.configYml" -}}
kafka_deadletter_topic: {{ required (printf "sentry.taskBroker.brokers[%s].kafkaDeadletterTopic is required" .broker.name) .broker.kafkaDeadletterTopic }}
kafka_retry_topic: {{ required (printf "sentry.taskBroker.brokers[%s].kafkaRetryTopic is required" .broker.name) .broker.kafkaRetryTopic }}

kafka_topics:
{{- range $topicName, $topic := .broker.kafkaTopics }}
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
{{- end -}}
