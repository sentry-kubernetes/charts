# Install

## Add repo

```
helm repo add sentry https://sentry-kubernetes.github.io/charts
```

## Without overrides

```
helm install sentry sentry/sentry --wait --timeout=1000s
```

## With your own values file

```
helm install sentry sentry/sentry -f values.yaml --wait --timeout=1000s
```

# Upgrade

Read the upgrade guide before upgrading to major versions of the chart.
[Upgrade Guide](docs/UPGRADE.md)

## Configuration

The following table lists the configurable parameters of the Sentry chart and their default values.

Note: this table is incomplete, so have a look at the values.yaml in case you miss something

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| asHook | bool | `true` |  |
| auth.register | bool | `true` |  |
| clickhouse.clickhouse.configmap.remote_servers.internal_replication | bool | `true` |  |
| clickhouse.clickhouse.configmap.remote_servers.replica.backup.enabled | bool | `false` |  |
| clickhouse.clickhouse.configmap.users.enabled | bool | `false` |  |
| clickhouse.clickhouse.configmap.users.user[0].config.networks[0] | string | `"::/0"` |  |
| clickhouse.clickhouse.configmap.users.user[0].config.password | string | `""` |  |
| clickhouse.clickhouse.configmap.users.user[0].config.profile | string | `"default"` |  |
| clickhouse.clickhouse.configmap.users.user[0].config.quota | string | `"default"` |  |
| clickhouse.clickhouse.configmap.users.user[0].name | string | `"default"` |  |
| clickhouse.clickhouse.configmap.zookeeper_servers.config[0].hostTemplate | string | `"{{ .Release.Name }}-zookeeper-clickhouse"` |  |
| clickhouse.clickhouse.configmap.zookeeper_servers.config[0].index | string | `"clickhouse"` |  |
| clickhouse.clickhouse.configmap.zookeeper_servers.config[0].port | string | `"2181"` |  |
| clickhouse.clickhouse.configmap.zookeeper_servers.enabled | bool | `true` |  |
| clickhouse.clickhouse.imageVersion | string | `"21.8.13.6"` |  |
| clickhouse.clickhouse.persistentVolumeClaim.dataPersistentVolume.accessModes[0] | string | `"ReadWriteOnce"` |  |
| clickhouse.clickhouse.persistentVolumeClaim.dataPersistentVolume.enabled | bool | `true` |  |
| clickhouse.clickhouse.persistentVolumeClaim.dataPersistentVolume.storage | string | `"30Gi"` |  |
| clickhouse.clickhouse.persistentVolumeClaim.enabled | bool | `true` |  |
| clickhouse.clickhouse.replicas | string | `"1"` |  |
| clickhouse.enabled | bool | `true` |  |
| config.configYml | object | `{}` |  |
| config.relay | string | `"# No YAML relay config given\n"` |  |
| config.sentryConfPy | string | `"# No Python Extension Config Given\n"` |  |
| config.snubaSettingsPy | string | `"# No Python Extension Config Given\n"` |  |
| config.web.httpKeepalive | int | `15` |  |
| config.web.maxRequests | int | `100000` |  |
| config.web.maxRequestsDelta | int | `500` |  |
| config.web.maxWorkerLifetime | int | `86400` |  |
| discord | object | `{}` |  |
| externalClickhouse.database | string | `"default"` |  |
| externalClickhouse.host | string | `"clickhouse"` |  |
| externalClickhouse.httpPort | int | `8123` |  |
| externalClickhouse.password | string | `""` |  |
| externalClickhouse.singleNode | bool | `true` |  |
| externalClickhouse.tcpPort | int | `9000` |  |
| externalClickhouse.username | string | `"default"` |  |
| externalKafka.cluster | list | `[]` | Multi hosts and ports of external Kafka |
| externalKafka.host | string | `"kafka-confluent"` | Hostname or IP address of external Kafka |
| externalKafka.port | int | `9092` | Port for external Kafka |
| externalKafka.compression.type | string | `""` | Compression type for Kafka messages ('gzip', 'snappy', 'lz4', 'zstd') |
| externalKafka.message.max.bytes | int | `50000000` | Maximum message size for Kafka |
| externalKafka.sasl.mechanism | string | `"None"` | SASL mechanism for Kafka (PLAIN, SCRAM-256, SCRAM-512) |
| externalKafka.sasl.username | string | `"None"` | SASL username for Kafka |
| externalKafka.sasl.password | string | `"None"` | SASL password for Kafka |
| externalKafka.security.protocol | string | `"plaintext"` | Security protocol for Kafka (PLAINTEXT, SASL_PLAINTEXT, SASL_SSL, SSL) |
| externalPostgresql.connMaxAge | int | `0` |  |
| externalPostgresql.database | string | `"sentry"` |  |
| externalPostgresql.existingSecretKeys | object | `{}` |  |
| externalPostgresql.port | int | `5432` |  |
| externalPostgresql.username | string | `"postgres"` |  |
| externalRedis.port | int | `6379` |  |
| extraManifests | list | `[]` |  |
| filestore.backend | string | `"filesystem"` |  |
| filestore.filesystem.path | string | `"/var/lib/sentry/files"` |  |
| filestore.filesystem.persistence.accessMode | string | `"ReadWriteOnce"` |  |
| filestore.filesystem.persistence.enabled | bool | `true` |  |
| filestore.filesystem.persistence.existingClaim | string | `""` |  |
| filestore.filesystem.persistence.persistentWorkers | bool | `false` |  |
| filestore.filesystem.persistence.size | string | `"10Gi"` |  |
| filestore.gcs | object | `{}` |  |
| filestore.s3 | object | `{}` |  |
| geodata.accountID | string | `""` |  |
| geodata.editionIDs | string | `""` |  |
| geodata.licenseKey | string | `""` |  |
| geodata.mountPath | string | `""` |  |
| geodata.path | string | `""` |  |
| geodata.persistence.size | string | `"1Gi"` |  |
| geodata.volumeName | string | `""` |  |
| github | object | `{}` |  |
| google | object | `{}` |  |
| hooks.activeDeadlineSeconds | int | `600` |  |
| hooks.dbCheck.affinity | object | `{}` |  |
| hooks.dbCheck.containerSecurityContext | object | `{}` |  |
| hooks.dbCheck.enabled | bool | `true` |  |
| hooks.dbCheck.env | list | `[]` |  |
| hooks.dbCheck.image.imagePullSecrets | list | `[]` |  |
| hooks.dbCheck.nodeSelector | object | `{}` |  |
| hooks.dbCheck.podAnnotations | object | `{}` |  |
| hooks.dbCheck.resources.limits.memory | string | `"64Mi"` |  |
| hooks.dbCheck.resources.requests.cpu | string | `"100m"` |  |
| hooks.dbCheck.resources.requests.memory | string | `"64Mi"` |  |
| hooks.dbCheck.securityContext | object | `{}` |  |
| hooks.dbInit.affinity | object | `{}` |  |
| hooks.dbInit.enabled | bool | `true` |  |
| hooks.dbInit.env | list | `[]` |  |
| hooks.dbInit.nodeSelector | object | `{}` |  |
| hooks.dbInit.podAnnotations | object | `{}` |  |
| hooks.dbInit.resources.limits.memory | string | `"2048Mi"` |  |
| hooks.dbInit.resources.requests.cpu | string | `"300m"` |  |
| hooks.dbInit.resources.requests.memory | string | `"2048Mi"` |  |
| hooks.dbInit.sidecars | list | `[]` |  |
| hooks.dbInit.volumes | list | `[]` |  |
| hooks.enabled | bool | `true` |  |
| hooks.preUpgrade | bool | `false` |  |
| hooks.removeOnSuccess | bool | `true` |  |
| hooks.shareProcessNamespace | bool | `false` |  |
| hooks.snubaInit.affinity | object | `{}` |  |
| hooks.snubaInit.enabled | bool | `true` |  |
| hooks.snubaInit.kafka.enabled | bool | `true` |  |
| hooks.snubaInit.nodeSelector | object | `{}` |  |
| hooks.snubaInit.podAnnotations | object | `{}` |  |
| hooks.snubaInit.resources.limits.cpu | string | `"2000m"` |  |
| hooks.snubaInit.resources.limits.memory | string | `"1Gi"` |  |
| hooks.snubaInit.resources.requests.cpu | string | `"700m"` |  |
| hooks.snubaInit.resources.requests.memory | string | `"1Gi"` |  |
| hooks.snubaMigrate.enabled | bool | `true` |  |
| images.relay.imagePullSecrets | list | `[]` |  |
| images.sentry.imagePullSecrets | list | `[]` |  |
| images.snuba.imagePullSecrets | list | `[]` |  |
| images.symbolicator.imagePullSecrets | list | `[]` |  |
| images.vroom.imagePullSecrets | list | `[]` |  |
| ingress.alb.httpRedirect | bool | `false` |  |
| ingress.enabled | bool | `true` |  |
| ingress.regexPathStyle | string | `"nginx"` |  |
| ipv6 | bool | `false` |  |
| kafka.controller.replicaCount | int | `3` |  |
| kafka.enabled | bool | `true` |  |
| kafka.kraft.enabled | bool | `true` |  |
| kafka.listeners.client.protocol | string | `"PLAINTEXT"` | Security protocol for the Kafka client listener (PLAINTEXT, SASL_PLAINTEXT, SASL_SSL, SSL) |
| kafka.listeners.controller.protocol | string | `"PLAINTEXT"` |  |
| kafka.listeners.external.protocol | string | `"PLAINTEXT"` |  |
| kafka.listeners.interbroker.protocol | string | `"PLAINTEXT"` |  |
| kafka.provisioning.enabled | bool | `true` |  |
| kafka.provisioning.topics[0].config."message.timestamp.type" | string | `"LogAppendTime"` |  |
| kafka.provisioning.topics[0].name | string | `"events"` |  |
| kafka.provisioning.topics[10].config."cleanup.policy" | string | `"compact,delete"` |  |
| kafka.provisioning.topics[10].config."min.compaction.lag.ms" | string | `"3600000"` |  |
| kafka.provisioning.topics[10].name | string | `"snuba-sessions-commit-log"` |  |
| kafka.provisioning.topics[11].config."cleanup.policy" | string | `"compact,delete"` |  |
| kafka.provisioning.topics[11].config."min.compaction.lag.ms" | string | `"3600000"` |  |
| kafka.provisioning.topics[11].name | string | `"snuba-metrics-commit-log"` |  |
| kafka.provisioning.topics[12].name | string | `"scheduled-subscriptions-events"` |  |
| kafka.provisioning.topics[13].name | string | `"scheduled-subscriptions-transactions"` |  |
| kafka.provisioning.topics[14].name | string | `"scheduled-subscriptions-sessions"` |  |
| kafka.provisioning.topics[15].name | string | `"scheduled-subscriptions-metrics"` |  |
| kafka.provisioning.topics[16].name | string | `"scheduled-subscriptions-generic-metrics-sets"` |  |
| kafka.provisioning.topics[17].name | string | `"scheduled-subscriptions-generic-metrics-distributions"` |  |
| kafka.provisioning.topics[18].name | string | `"scheduled-subscriptions-generic-metrics-counters"` |  |
| kafka.provisioning.topics[19].name | string | `"events-subscription-results"` |  |
| kafka.provisioning.topics[1].name | string | `"event-replacements"` |  |
| kafka.provisioning.topics[20].name | string | `"transactions-subscription-results"` |  |
| kafka.provisioning.topics[21].name | string | `"sessions-subscription-results"` |  |
| kafka.provisioning.topics[22].name | string | `"metrics-subscription-results"` |  |
| kafka.provisioning.topics[23].name | string | `"generic-metrics-subscription-results"` |  |
| kafka.provisioning.topics[24].config."message.timestamp.type" | string | `"LogAppendTime"` |  |
| kafka.provisioning.topics[24].name | string | `"snuba-queries"` |  |
| kafka.provisioning.topics[25].config."message.timestamp.type" | string | `"LogAppendTime"` |  |
| kafka.provisioning.topics[25].name | string | `"processed-profiles"` |  |
| kafka.provisioning.topics[26].name | string | `"profiles-call-tree"` |  |
| kafka.provisioning.topics[27].config."max.message.bytes" | string | `"15000000"` |  |
| kafka.provisioning.topics[27].config."message.timestamp.type" | string | `"LogAppendTime"` |  |
| kafka.provisioning.topics[27].name | string | `"ingest-replay-events"` |  |
| kafka.provisioning.topics[28].config."message.timestamp.type" | string | `"LogAppendTime"` |  |
| kafka.provisioning.topics[28].name | string | `"snuba-generic-metrics"` |  |
| kafka.provisioning.topics[29].config."cleanup.policy" | string | `"compact,delete"` |  |
| kafka.provisioning.topics[29].config."min.compaction.lag.ms" | string | `"3600000"` |  |
| kafka.provisioning.topics[29].name | string | `"snuba-generic-metrics-sets-commit-log"` |  |
| kafka.provisioning.topics[2].config."cleanup.policy" | string | `"compact,delete"` |  |
| kafka.provisioning.topics[2].config."min.compaction.lag.ms" | string | `"3600000"` |  |
| kafka.provisioning.topics[2].name | string | `"snuba-commit-log"` |  |
| kafka.provisioning.topics[30].config."cleanup.policy" | string | `"compact,delete"` |  |
| kafka.provisioning.topics[30].config."min.compaction.lag.ms" | string | `"3600000"` |  |
| kafka.provisioning.topics[30].name | string | `"snuba-generic-metrics-distributions-commit-log"` |  |
| kafka.provisioning.topics[31].config."cleanup.policy" | string | `"compact,delete"` |  |
| kafka.provisioning.topics[31].config."min.compaction.lag.ms" | string | `"3600000"` |  |
| kafka.provisioning.topics[31].name | string | `"snuba-generic-metrics-counters-commit-log"` |  |
| kafka.provisioning.topics[32].config."message.timestamp.type" | string | `"LogAppendTime"` |  |
| kafka.provisioning.topics[32].name | string | `"generic-events"` |  |
| kafka.provisioning.topics[33].config."cleanup.policy" | string | `"compact,delete"` |  |
| kafka.provisioning.topics[33].config."min.compaction.lag.ms" | string | `"3600000"` |  |
| kafka.provisioning.topics[33].name | string | `"snuba-generic-events-commit-log"` |  |
| kafka.provisioning.topics[34].config."message.timestamp.type" | string | `"LogAppendTime"` |  |
| kafka.provisioning.topics[34].name | string | `"group-attributes"` |  |
| kafka.provisioning.topics[35].name | string | `"snuba-attribution"` |  |
| kafka.provisioning.topics[36].name | string | `"snuba-dead-letter-metrics"` |  |
| kafka.provisioning.topics[37].name | string | `"snuba-dead-letter-sessions"` |  |
| kafka.provisioning.topics[38].name | string | `"snuba-dead-letter-generic-metrics"` |  |
| kafka.provisioning.topics[39].name | string | `"snuba-dead-letter-replays"` |  |
| kafka.provisioning.topics[3].name | string | `"cdc"` |  |
| kafka.provisioning.topics[40].name | string | `"snuba-dead-letter-generic-events"` |  |
| kafka.provisioning.topics[41].name | string | `"snuba-dead-letter-querylog"` |  |
| kafka.provisioning.topics[42].name | string | `"snuba-dead-letter-group-attributes"` |  |
| kafka.provisioning.topics[43].name | string | `"ingest-attachments"` |  |
| kafka.provisioning.topics[44].name | string | `"ingest-transactions"` |  |
| kafka.provisioning.topics[45].name | string | `"ingest-events"` |  |
| kafka.provisioning.topics[46].name | string | `"ingest-replay-recordings"` |  |
| kafka.provisioning.topics[47].name | string | `"ingest-metrics"` |  |
| kafka.provisioning.topics[48].name | string | `"ingest-performance-metrics"` |  |
| kafka.provisioning.topics[49].name | string | `"ingest-monitors"` |  |
| kafka.provisioning.topics[4].config."message.timestamp.type" | string | `"LogAppendTime"` |  |
| kafka.provisioning.topics[4].name | string | `"transactions"` |  |
| kafka.provisioning.topics[50].name | string | `"profiles"` |  |
| kafka.provisioning.topics[51].name | string | `"ingest-occurrences"` |  |
| kafka.provisioning.topics[52].name | string | `"snuba-spans"` |  |
| kafka.provisioning.topics[53].name | string | `"shared-resources-usage"` |  |
| kafka.provisioning.topics[54].name | string | `"snuba-metrics-summaries"` |  |
| kafka.provisioning.topics[5].config."cleanup.policy" | string | `"compact,delete"` |  |
| kafka.provisioning.topics[5].config."min.compaction.lag.ms" | string | `"3600000"` |  |
| kafka.provisioning.topics[5].name | string | `"snuba-transactions-commit-log"` |  |
| kafka.provisioning.topics[6].config."message.timestamp.type" | string | `"LogAppendTime"` |  |
| kafka.provisioning.topics[6].name | string | `"snuba-metrics"` |  |
| kafka.provisioning.topics[7].name | string | `"outcomes"` |  |
| kafka.provisioning.topics[8].name | string | `"outcomes-billing"` |  |
| kafka.provisioning.topics[9].name | string | `"ingest-sessions"` |  |
| kafka.sasl.client.users | list | `[]` | List of usernames for client communications when SASL is enabled, first user will be used if enabled |
| kafka.sasl.client.passwords | list | `[]` | List of passwords for client communications when SASL is enabled, must match the number of client.users, first password will be used if enabled |
| kafka.sasl.enabledMechanisms | string | `"PLAIN,SCRAM-SHA-256,SCRAM-SHA-512"` | Comma-separated list of allowed SASL mechanisms when SASL listeners are configured |
| kafka.zookeeper.enabled | bool | `false` |  |
| mail.backend | string | `"dummy"` |  |
| mail.from | string | `""` |  |
| mail.host | string | `""` |  |
| mail.password | string | `""` |  |
| mail.port | int | `25` |  |
| mail.useSsl | bool | `false` |  |
| mail.useTls | bool | `false` |  |
| mail.username | string | `""` |  |
| memcached.args[0] | string | `"memcached"` |  |
| memcached.args[1] | string | `"-u memcached"` |  |
| memcached.args[2] | string | `"-p 11211"` |  |
| memcached.args[3] | string | `"-v"` |  |
| memcached.args[4] | string | `"-m $(MEMCACHED_MEMORY_LIMIT)"` |  |
| memcached.args[5] | string | `"-I $(MEMCACHED_MAX_ITEM_SIZE)"` |  |
| memcached.extraEnvVarsCM | string | `"sentry-memcached"` |  |
| memcached.maxItemSize | string | `"26214400"` |  |
| memcached.memoryLimit | string | `"2048"` |  |
| metrics.affinity | object | `{}` |  |
| metrics.containerSecurityContext | object | `{}` |  |
| metrics.enabled | bool | `false` |  |
| metrics.image.pullPolicy | string | `"IfNotPresent"` |  |
| metrics.image.repository | string | `"prom/statsd-exporter"` |  |
| metrics.image.tag | string | `"v0.17.0"` |  |
| metrics.livenessProbe.enabled | bool | `true` |  |
| metrics.livenessProbe.failureThreshold | int | `3` |  |
| metrics.livenessProbe.initialDelaySeconds | int | `30` |  |
| metrics.livenessProbe.periodSeconds | int | `5` |  |
| metrics.livenessProbe.successThreshold | int | `1` |  |
| metrics.livenessProbe.timeoutSeconds | int | `2` |  |
| metrics.nodeSelector | object | `{}` |  |
| metrics.podAnnotations | object | `{}` |  |
| metrics.readinessProbe.enabled | bool | `true` |  |
| metrics.readinessProbe.failureThreshold | int | `3` |  |
| metrics.readinessProbe.initialDelaySeconds | int | `30` |  |
| metrics.readinessProbe.periodSeconds | int | `5` |  |
| metrics.readinessProbe.successThreshold | int | `1` |  |
| metrics.readinessProbe.timeoutSeconds | int | `2` |  |
| metrics.resources | object | `{}` |  |
| metrics.securityContext | object | `{}` |  |
| metrics.service.labels | object | `{}` |  |
| metrics.service.type | string | `"ClusterIP"` |  |
| metrics.serviceMonitor.additionalLabels | object | `{}` |  |
| metrics.serviceMonitor.enabled | bool | `false` |  |
| metrics.serviceMonitor.metricRelabelings | list | `[]` |  |
| metrics.serviceMonitor.namespace | string | `""` |  |
| metrics.serviceMonitor.namespaceSelector | object | `{}` |  |
| metrics.serviceMonitor.relabelings | list | `[]` |  |
| metrics.serviceMonitor.scrapeInterval | string | `"30s"` |  |
| metrics.tolerations | list | `[]` |  |
| nginx.containerPort | int | `8080` |  |
| nginx.customReadinessProbe.failureThreshold | int | `3` |  |
| nginx.customReadinessProbe.initialDelaySeconds | int | `5` |  |
| nginx.customReadinessProbe.periodSeconds | int | `5` |  |
| nginx.customReadinessProbe.successThreshold | int | `1` |  |
| nginx.customReadinessProbe.tcpSocket.port | string | `"http"` |  |
| nginx.customReadinessProbe.timeoutSeconds | int | `3` |  |
| nginx.enabled | bool | `true` |  |
| nginx.existingServerBlockConfigmap | string | `"{{ template \"sentry.fullname\" . }}"` |  |
| nginx.extraLocationSnippet | bool | `false` |  |
| nginx.metrics.serviceMonitor | object | `{}` |  |
| nginx.replicaCount | int | `1` |  |
| nginx.resources | object | `{}` |  |
| nginx.service.ports.http | int | `80` |  |
| nginx.service.type | string | `"ClusterIP"` |  |
| openai | object | `{}` |  |
| postgresql.auth.database | string | `"sentry"` |  |
| postgresql.connMaxAge | int | `0` |  |
| postgresql.enabled | bool | `true` |  |
| postgresql.nameOverride | string | `"sentry-postgresql"` |  |
| postgresql.replication.applicationName | string | `"sentry"` |  |
| postgresql.replication.enabled | bool | `false` |  |
| postgresql.replication.numSynchronousReplicas | int | `1` |  |
| postgresql.replication.readReplicas | int | `2` |  |
| postgresql.replication.synchronousCommit | string | `"on"` |  |
| prefix | string | `nil` |  |
| rabbitmq.auth.erlangCookie | string | `"pHgpy3Q6adTskzAT6bLHCFqFTF7lMxhA"` |  |
| rabbitmq.auth.password | string | `"guest"` |  |
| rabbitmq.auth.username | string | `"guest"` |  |
| rabbitmq.clustering.forceBoot | bool | `true` |  |
| rabbitmq.clustering.rebalance | bool | `true` |  |
| rabbitmq.enabled | bool | `true` |  |
| rabbitmq.extraConfiguration | string | `"load_definitions = /app/load_definition.json\n"` |  |
| rabbitmq.extraSecrets.load-definition."load_definition.json" | string | `"{\n  \"users\": [\n    {\n      \"name\": \"{{ .Values.auth.username }}\",\n      \"password\": \"{{ .Values.auth.password }}\",\n      \"tags\": \"administrator\"\n    }\n  ],\n  \"permissions\": [{\n    \"user\": \"{{ .Values.auth.username }}\",\n    \"vhost\": \"/\",\n    \"configure\": \".*\",\n    \"write\": \".*\",\n    \"read\": \".*\"\n  }],\n  \"policies\": [\n    {\n      \"name\": \"ha-all\",\n      \"pattern\": \".*\",\n      \"vhost\": \"/\",\n      \"definition\": {\n        \"ha-mode\": \"all\",\n        \"ha-sync-mode\": \"automatic\",\n        \"ha-sync-batch-size\": 1\n      }\n    }\n  ],\n  \"vhosts\": [\n    {\n      \"name\": \"/\"\n    }\n  ]\n}\n"` |  |
| rabbitmq.loadDefinition.enabled | bool | `true` |  |
| rabbitmq.loadDefinition.existingSecret | string | `"load-definition"` |  |
| rabbitmq.memoryHighWatermark | object | `{}` |  |
| rabbitmq.nameOverride | string | `""` |  |
| rabbitmq.pdb.create | bool | `true` |  |
| rabbitmq.persistence.enabled | bool | `true` |  |
| rabbitmq.replicaCount | int | `1` |  |
| rabbitmq.resources | object | `{}` |  |
| rabbitmq.vhost | string | `"/"` |  |
| redis.auth.enabled | bool | `false` |  |
| redis.auth.sentinel | bool | `false` |  |
| redis.enabled | bool | `true` |  |
| redis.master.persistence.enabled | bool | `true` |  |
| redis.nameOverride | string | `"sentry-redis"` |  |
| redis.replica.replicaCount | int | `1` |  |
| relay.affinity | object | `{}` |  |
| relay.autoscaling.enabled | bool | `false` |  |
| relay.autoscaling.maxReplicas | int | `5` |  |
| relay.autoscaling.minReplicas | int | `2` |  |
| relay.autoscaling.targetCPUUtilizationPercentage | int | `50` |  |
| relay.containerSecurityContext | object | `{}` |  |
| relay.customResponseHeaders | list | `[]` |  |
| relay.enabled | bool | `true` |  |
| relay.env | list | `[]` |  |
| relay.init.resources | object | `{}` |  |
| relay.mode | string | `"managed"` |  |
| relay.nodeSelector | object | `{}` |  |
| relay.probeFailureThreshold | int | `5` |  |
| relay.probeInitialDelaySeconds | int | `10` |  |
| relay.probePeriodSeconds | int | `10` |  |
| relay.probeSuccessThreshold | int | `1` |  |
| relay.probeTimeoutSeconds | int | `2` |  |
| relay.processing.kafkaConfig.messageMaxBytes | int | `50000000` |  |
| relay.replicas | int | `1` |  |
| relay.resources | object | `{}` |  |
| relay.securityContext | object | `{}` |  |
| relay.securityPolicy | string | `""` |  |
| relay.service.annotations | object | `{}` |  |
| relay.sidecars | list | `[]` |  |
| relay.topologySpreadConstraints | list | `[]` |  |
| relay.volumeMounts | list | `[]` |  |
| relay.volumes | list | `[]` |  |
| revisionHistoryLimit | int | `10` |  |
| sentry.billingMetricsConsumer.affinity | object | `{}` |  |
| sentry.billingMetricsConsumer.autoscaling.enabled | bool | `false` |  |
| sentry.billingMetricsConsumer.autoscaling.maxReplicas | int | `3` |  |
| sentry.billingMetricsConsumer.autoscaling.minReplicas | int | `1` |  |
| sentry.billingMetricsConsumer.autoscaling.targetCPUUtilizationPercentage | int | `50` |  |
| sentry.billingMetricsConsumer.containerSecurityContext | object | `{}` |  |
| sentry.billingMetricsConsumer.enabled | bool | `true` |  |
| sentry.billingMetricsConsumer.env | list | `[]` |  |
| sentry.billingMetricsConsumer.livenessProbe.enabled | bool | `true` |  |
| sentry.billingMetricsConsumer.livenessProbe.initialDelaySeconds | int | `5` |  |
| sentry.billingMetricsConsumer.livenessProbe.periodSeconds | int | `320` |  |
| sentry.billingMetricsConsumer.nodeSelector | object | `{}` |  |
| sentry.billingMetricsConsumer.replicas | int | `1` |  |
| sentry.billingMetricsConsumer.resources | object | `{}` |  |
| sentry.billingMetricsConsumer.securityContext | object | `{}` |  |
| sentry.billingMetricsConsumer.sidecars | list | `[]` |  |
| sentry.billingMetricsConsumer.topologySpreadConstraints | list | `[]` |  |
| sentry.billingMetricsConsumer.volumes | list | `[]` |  |
| sentry.cleanup.activeDeadlineSeconds | int | `100` |  |
| sentry.cleanup.concurrency | int | `1` |  |
| sentry.cleanup.concurrencyPolicy | string | `"Allow"` |  |
| sentry.cleanup.days | int | `90` |  |
| sentry.cleanup.enabled | bool | `true` |  |
| sentry.cleanup.failedJobsHistoryLimit | int | `5` |  |
| sentry.cleanup.logLevel | string | `""` |  |
| sentry.cleanup.schedule | string | `"0 0 * * *"` |  |
| sentry.cleanup.serviceAccount | object | `{}` |  |
| sentry.cleanup.sidecars | list | `[]` |  |
| sentry.cleanup.successfulJobsHistoryLimit | int | `5` |  |
| sentry.cleanup.volumes | list | `[]` |  |
| sentry.cron.affinity | object | `{}` |  |
| sentry.cron.enabled | bool | `true` |  |
| sentry.cron.env | list | `[]` |  |
| sentry.cron.nodeSelector | object | `{}` |  |
| sentry.cron.replicas | int | `1` |  |
| sentry.cron.resources | object | `{}` |  |
| sentry.cron.sidecars | list | `[]` |  |
| sentry.cron.topologySpreadConstraints | list | `[]` |  |
| sentry.cron.volumes | list | `[]` |  |
| sentry.features.enableFeedback | bool | `false` |  |
| sentry.features.enableProfiling | bool | `false` |  |
| sentry.features.enableSessionReplay | bool | `true` |  |
| sentry.features.enableSpan | bool | `false` |  |
| sentry.features.orgSubdomains | bool | `false` |  |
| sentry.features.vstsLimitedScopes | bool | `true` |  |
| sentry.genericMetricsConsumer.affinity | object | `{}` |  |
| sentry.genericMetricsConsumer.autoscaling.enabled | bool | `false` |  |
| sentry.genericMetricsConsumer.autoscaling.maxReplicas | int | `3` |  |
| sentry.genericMetricsConsumer.autoscaling.minReplicas | int | `1` |  |
| sentry.genericMetricsConsumer.autoscaling.targetCPUUtilizationPercentage | int | `50` |  |
| sentry.genericMetricsConsumer.containerSecurityContext | object | `{}` |  |
| sentry.genericMetricsConsumer.enabled | bool | `true` |  |
| sentry.genericMetricsConsumer.env | list | `[]` |  |
| sentry.genericMetricsConsumer.livenessProbe.enabled | bool | `true` |  |
| sentry.genericMetricsConsumer.livenessProbe.initialDelaySeconds | int | `5` |  |
| sentry.genericMetricsConsumer.livenessProbe.periodSeconds | int | `320` |  |
| sentry.genericMetricsConsumer.nodeSelector | object | `{}` |  |
| sentry.genericMetricsConsumer.replicas | int | `1` |  |
| sentry.genericMetricsConsumer.resources | object | `{}` |  |
| sentry.genericMetricsConsumer.securityContext | object | `{}` |  |
| sentry.genericMetricsConsumer.sidecars | list | `[]` |  |
| sentry.genericMetricsConsumer.topologySpreadConstraints | list | `[]` |  |
| sentry.genericMetricsConsumer.volumes | list | `[]` |  |
| sentry.ingestConsumerAttachments.affinity | object | `{}` |  |
| sentry.ingestConsumerAttachments.autoscaling.enabled | bool | `false` |  |
| sentry.ingestConsumerAttachments.autoscaling.maxReplicas | int | `3` |  |
| sentry.ingestConsumerAttachments.autoscaling.minReplicas | int | `1` |  |
| sentry.ingestConsumerAttachments.autoscaling.targetCPUUtilizationPercentage | int | `50` |  |
| sentry.ingestConsumerAttachments.containerSecurityContext | object | `{}` |  |
| sentry.ingestConsumerAttachments.enabled | bool | `true` |  |
| sentry.ingestConsumerAttachments.env | list | `[]` |  |
| sentry.ingestConsumerAttachments.livenessProbe.enabled | bool | `true` |  |
| sentry.ingestConsumerAttachments.livenessProbe.initialDelaySeconds | int | `5` |  |
| sentry.ingestConsumerAttachments.livenessProbe.periodSeconds | int | `320` |  |
| sentry.ingestConsumerAttachments.nodeSelector | object | `{}` |  |
| sentry.ingestConsumerAttachments.replicas | int | `1` |  |
| sentry.ingestConsumerAttachments.resources | object | `{}` |  |
| sentry.ingestConsumerAttachments.securityContext | object | `{}` |  |
| sentry.ingestConsumerAttachments.sidecars | list | `[]` |  |
| sentry.ingestConsumerAttachments.topologySpreadConstraints | list | `[]` |  |
| sentry.ingestConsumerAttachments.volumes | list | `[]` |  |
| sentry.ingestConsumerEvents.affinity | object | `{}` |  |
| sentry.ingestConsumerEvents.autoscaling.enabled | bool | `false` |  |
| sentry.ingestConsumerEvents.autoscaling.maxReplicas | int | `3` |  |
| sentry.ingestConsumerEvents.autoscaling.minReplicas | int | `1` |  |
| sentry.ingestConsumerEvents.autoscaling.targetCPUUtilizationPercentage | int | `50` |  |
| sentry.ingestConsumerEvents.containerSecurityContext | object | `{}` |  |
| sentry.ingestConsumerEvents.enabled | bool | `true` |  |
| sentry.ingestConsumerEvents.env | list | `[]` |  |
| sentry.ingestConsumerEvents.livenessProbe.enabled | bool | `true` |  |
| sentry.ingestConsumerEvents.livenessProbe.initialDelaySeconds | int | `5` |  |
| sentry.ingestConsumerEvents.livenessProbe.periodSeconds | int | `320` |  |
| sentry.ingestConsumerEvents.nodeSelector | object | `{}` |  |
| sentry.ingestConsumerEvents.replicas | int | `1` |  |
| sentry.ingestConsumerEvents.resources | object | `{}` |  |
| sentry.ingestConsumerEvents.securityContext | object | `{}` |  |
| sentry.ingestConsumerEvents.sidecars | list | `[]` |  |
| sentry.ingestConsumerEvents.topologySpreadConstraints | list | `[]` |  |
| sentry.ingestConsumerEvents.volumes | list | `[]` |  |
| sentry.ingestConsumerTransactions.affinity | object | `{}` |  |
| sentry.ingestConsumerTransactions.autoscaling.enabled | bool | `false` |  |
| sentry.ingestConsumerTransactions.autoscaling.maxReplicas | int | `3` |  |
| sentry.ingestConsumerTransactions.autoscaling.minReplicas | int | `1` |  |
| sentry.ingestConsumerTransactions.autoscaling.targetCPUUtilizationPercentage | int | `50` |  |
| sentry.ingestConsumerTransactions.containerSecurityContext | object | `{}` |  |
| sentry.ingestConsumerTransactions.enabled | bool | `true` |  |
| sentry.ingestConsumerTransactions.env | list | `[]` |  |
| sentry.ingestConsumerTransactions.livenessProbe.enabled | bool | `true` |  |
| sentry.ingestConsumerTransactions.livenessProbe.initialDelaySeconds | int | `5` |  |
| sentry.ingestConsumerTransactions.livenessProbe.periodSeconds | int | `320` |  |
| sentry.ingestConsumerTransactions.nodeSelector | object | `{}` |  |
| sentry.ingestConsumerTransactions.replicas | int | `1` |  |
| sentry.ingestConsumerTransactions.resources | object | `{}` |  |
| sentry.ingestConsumerTransactions.securityContext | object | `{}` |  |
| sentry.ingestConsumerTransactions.sidecars | list | `[]` |  |
| sentry.ingestConsumerTransactions.topologySpreadConstraints | list | `[]` |  |
| sentry.ingestConsumerTransactions.volumes | list | `[]` |  |
| sentry.ingestFeedback.affinity | object | `{}` |  |
| sentry.ingestFeedback.autoscaling.enabled | bool | `false` |  |
| sentry.ingestFeedback.autoscaling.maxReplicas | int | `3` |  |
| sentry.ingestFeedback.autoscaling.minReplicas | int | `1` |  |
| sentry.ingestFeedback.autoscaling.targetCPUUtilizationPercentage | int | `50` |  |
| sentry.ingestFeedback.containerSecurityContext | object | `{}` |  |
| sentry.ingestFeedback.enabled | bool | `true` |  |
| sentry.ingestFeedback.env | list | `[]` |  |
| sentry.ingestFeedback.livenessProbe.enabled | bool | `true` |  |
| sentry.ingestFeedback.livenessProbe.initialDelaySeconds | int | `5` |  |
| sentry.ingestFeedback.livenessProbe.periodSeconds | int | `320` |  |
| sentry.ingestFeedback.nodeSelector | object | `{}` |  |
| sentry.ingestFeedback.replicas | int | `1` |  |
| sentry.ingestFeedback.resources | object | `{}` |  |
| sentry.ingestFeedback.securityContext | object | `{}` |  |
| sentry.ingestFeedback.sidecars | list | `[]` |  |
| sentry.ingestFeedback.topologySpreadConstraints | list | `[]` |  |
| sentry.ingestFeedback.volumes | list | `[]` |  |
| sentry.ingestMonitors.affinity | object | `{}` |  |
| sentry.ingestMonitors.autoscaling.enabled | bool | `false` |  |
| sentry.ingestMonitors.autoscaling.maxReplicas | int | `3` |  |
| sentry.ingestMonitors.autoscaling.minReplicas | int | `1` |  |
| sentry.ingestMonitors.autoscaling.targetCPUUtilizationPercentage | int | `50` |  |
| sentry.ingestMonitors.containerSecurityContext | object | `{}` |  |
| sentry.ingestMonitors.enabled | bool | `true` |  |
| sentry.ingestMonitors.env | list | `[]` |  |
| sentry.ingestMonitors.livenessProbe.enabled | bool | `true` |  |
| sentry.ingestMonitors.livenessProbe.initialDelaySeconds | int | `5` |  |
| sentry.ingestMonitors.livenessProbe.periodSeconds | int | `320` |  |
| sentry.ingestMonitors.nodeSelector | object | `{}` |  |
| sentry.ingestMonitors.replicas | int | `1` |  |
| sentry.ingestMonitors.resources | object | `{}` |  |
| sentry.ingestMonitors.securityContext | object | `{}` |  |
| sentry.ingestMonitors.sidecars | list | `[]` |  |
| sentry.ingestMonitors.topologySpreadConstraints | list | `[]` |  |
| sentry.ingestMonitors.volumes | list | `[]` |  |
| sentry.ingestOccurrences.affinity | object | `{}` |  |
| sentry.ingestOccurrences.autoscaling.enabled | bool | `false` |  |
| sentry.ingestOccurrences.autoscaling.maxReplicas | int | `3` |  |
| sentry.ingestOccurrences.autoscaling.minReplicas | int | `1` |  |
| sentry.ingestOccurrences.autoscaling.targetCPUUtilizationPercentage | int | `50` |  |
| sentry.ingestOccurrences.containerSecurityContext | object | `{}` |  |
| sentry.ingestOccurrences.enabled | bool | `true` |  |
| sentry.ingestOccurrences.env | list | `[]` |  |
| sentry.ingestOccurrences.livenessProbe.enabled | bool | `true` |  |
| sentry.ingestOccurrences.livenessProbe.initialDelaySeconds | int | `5` |  |
| sentry.ingestOccurrences.livenessProbe.periodSeconds | int | `320` |  |
| sentry.ingestOccurrences.nodeSelector | object | `{}` |  |
| sentry.ingestOccurrences.replicas | int | `1` |  |
| sentry.ingestOccurrences.resources | object | `{}` |  |
| sentry.ingestOccurrences.securityContext | object | `{}` |  |
| sentry.ingestOccurrences.sidecars | list | `[]` |  |
| sentry.ingestOccurrences.topologySpreadConstraints | list | `[]` |  |
| sentry.ingestOccurrences.volumes | list | `[]` |  |
| sentry.ingestProfiles.affinity | object | `{}` |  |
| sentry.ingestProfiles.autoscaling.enabled | bool | `false` |  |
| sentry.ingestProfiles.autoscaling.maxReplicas | int | `3` |  |
| sentry.ingestProfiles.autoscaling.minReplicas | int | `1` |  |
| sentry.ingestProfiles.autoscaling.targetCPUUtilizationPercentage | int | `50` |  |
| sentry.ingestProfiles.containerSecurityContext | object | `{}` |  |
| sentry.ingestProfiles.env | list | `[]` |  |
| sentry.ingestProfiles.livenessProbe.enabled | bool | `true` |  |
| sentry.ingestProfiles.livenessProbe.initialDelaySeconds | int | `5` |  |
| sentry.ingestProfiles.livenessProbe.periodSeconds | int | `320` |  |
| sentry.ingestProfiles.nodeSelector | object | `{}` |  |
| sentry.ingestProfiles.replicas | int | `1` |  |
| sentry.ingestProfiles.resources | object | `{}` |  |
| sentry.ingestProfiles.securityContext | object | `{}` |  |
| sentry.ingestProfiles.sidecars | list | `[]` |  |
| sentry.ingestProfiles.topologySpreadConstraints | list | `[]` |  |
| sentry.ingestProfiles.volumes | list | `[]` |  |
| sentry.ingestReplayRecordings.affinity | object | `{}` |  |
| sentry.ingestReplayRecordings.autoscaling.enabled | bool | `false` |  |
| sentry.ingestReplayRecordings.autoscaling.maxReplicas | int | `3` |  |
| sentry.ingestReplayRecordings.autoscaling.minReplicas | int | `1` |  |
| sentry.ingestReplayRecordings.autoscaling.targetCPUUtilizationPercentage | int | `50` |  |
| sentry.ingestReplayRecordings.containerSecurityContext | object | `{}` |  |
| sentry.ingestReplayRecordings.enabled | bool | `true` |  |
| sentry.ingestReplayRecordings.env | list | `[]` |  |
| sentry.ingestReplayRecordings.livenessProbe.enabled | bool | `true` |  |
| sentry.ingestReplayRecordings.livenessProbe.initialDelaySeconds | int | `5` |  |
| sentry.ingestReplayRecordings.livenessProbe.periodSeconds | int | `320` |  |
| sentry.ingestReplayRecordings.nodeSelector | object | `{}` |  |
| sentry.ingestReplayRecordings.replicas | int | `1` |  |
| sentry.ingestReplayRecordings.resources | object | `{}` |  |
| sentry.ingestReplayRecordings.securityContext | object | `{}` |  |
| sentry.ingestReplayRecordings.sidecars | list | `[]` |  |
| sentry.ingestReplayRecordings.topologySpreadConstraints | list | `[]` |  |
| sentry.ingestReplayRecordings.volumes | list | `[]` |  |
| sentry.kafka.message.max.bytes | int | `50000000` | Maximum message size for Kafka |
| sentry.kafka.compression.type | string | `""` | Compression type for Kafka messages |
| sentry.kafka.socket.timeout.ms | int | `1000` | Socket timeout for Kafka connections |
| sentry.metricsConsumer.affinity | object | `{}` |  |
| sentry.metricsConsumer.autoscaling.enabled | bool | `false` |  |
| sentry.metricsConsumer.autoscaling.maxReplicas | int | `3` |  |
| sentry.metricsConsumer.autoscaling.minReplicas | int | `1` |  |
| sentry.metricsConsumer.autoscaling.targetCPUUtilizationPercentage | int | `50` |  |
| sentry.metricsConsumer.containerSecurityContext | object | `{}` |  |
| sentry.metricsConsumer.enabled | bool | `true` |  |
| sentry.metricsConsumer.env | list | `[]` |  |
| sentry.metricsConsumer.livenessProbe.enabled | bool | `true` |  |
| sentry.metricsConsumer.livenessProbe.initialDelaySeconds | int | `5` |  |
| sentry.metricsConsumer.livenessProbe.periodSeconds | int | `320` |  |
| sentry.metricsConsumer.nodeSelector | object | `{}` |  |
| sentry.metricsConsumer.replicas | int | `1` |  |
| sentry.metricsConsumer.resources | object | `{}` |  |
| sentry.metricsConsumer.securityContext | object | `{}` |  |
| sentry.metricsConsumer.sidecars | list | `[]` |  |
| sentry.metricsConsumer.topologySpreadConstraints | list | `[]` |  |
| sentry.metricsConsumer.volumes | list | `[]` |  |
| sentry.postProcessForwardErrors.affinity | object | `{}` |  |
| sentry.postProcessForwardErrors.containerSecurityContext | object | `{}` |  |
| sentry.postProcessForwardErrors.enabled | bool | `true` |  |
| sentry.postProcessForwardErrors.env | list | `[]` |  |
| sentry.postProcessForwardErrors.livenessProbe.enabled | bool | `true` |  |
| sentry.postProcessForwardErrors.livenessProbe.initialDelaySeconds | int | `5` |  |
| sentry.postProcessForwardErrors.livenessProbe.periodSeconds | int | `320` |  |
| sentry.postProcessForwardErrors.nodeSelector | object | `{}` |  |
| sentry.postProcessForwardErrors.replicas | int | `1` |  |
| sentry.postProcessForwardErrors.resources | object | `{}` |  |
| sentry.postProcessForwardErrors.securityContext | object | `{}` |  |
| sentry.postProcessForwardErrors.sidecars | list | `[]` |  |
| sentry.postProcessForwardErrors.topologySpreadConstraints | list | `[]` |  |
| sentry.postProcessForwardErrors.volumes | list | `[]` |  |
| sentry.postProcessForwardIssuePlatform.affinity | object | `{}` |  |
| sentry.postProcessForwardIssuePlatform.containerSecurityContext | object | `{}` |  |
| sentry.postProcessForwardIssuePlatform.enabled | bool | `true` |  |
| sentry.postProcessForwardIssuePlatform.env | list | `[]` |  |
| sentry.postProcessForwardIssuePlatform.livenessProbe.enabled | bool | `true` |  |
| sentry.postProcessForwardIssuePlatform.livenessProbe.initialDelaySeconds | int | `5` |  |
| sentry.postProcessForwardIssuePlatform.livenessProbe.periodSeconds | int | `320` |  |
| sentry.postProcessForwardIssuePlatform.nodeSelector | object | `{}` |  |
| sentry.postProcessForwardIssuePlatform.replicas | int | `1` |  |
| sentry.postProcessForwardIssuePlatform.resources | object | `{}` |  |
| sentry.postProcessForwardIssuePlatform.securityContext | object | `{}` |  |
| sentry.postProcessForwardIssuePlatform.sidecars | list | `[]` |  |
| sentry.postProcessForwardIssuePlatform.topologySpreadConstraints | list | `[]` |  |
| sentry.postProcessForwardIssuePlatform.volumes | list | `[]` |  |
| sentry.postProcessForwardTransactions.affinity | object | `{}` |  |
| sentry.postProcessForwardTransactions.containerSecurityContext | object | `{}` |  |
| sentry.postProcessForwardTransactions.enabled | bool | `true` |  |
| sentry.postProcessForwardTransactions.env | list | `[]` |  |
| sentry.postProcessForwardTransactions.livenessProbe.enabled | bool | `true` |  |
| sentry.postProcessForwardTransactions.livenessProbe.initialDelaySeconds | int | `5` |  |
| sentry.postProcessForwardTransactions.livenessProbe.periodSeconds | int | `320` |  |
| sentry.postProcessForwardTransactions.nodeSelector | object | `{}` |  |
| sentry.postProcessForwardTransactions.replicas | int | `1` |  |
| sentry.postProcessForwardTransactions.resources | object | `{}` |  |
| sentry.postProcessForwardTransactions.securityContext | object | `{}` |  |
| sentry.postProcessForwardTransactions.sidecars | list | `[]` |  |
| sentry.postProcessForwardTransactions.topologySpreadConstraints | list | `[]` |  |
| sentry.postProcessForwardTransactions.volumes | list | `[]` |  |
| sentry.singleOrganization | bool | `true` |  |
| sentry.subscriptionConsumerEvents.affinity | object | `{}` |  |
| sentry.subscriptionConsumerEvents.containerSecurityContext | object | `{}` |  |
| sentry.subscriptionConsumerEvents.enabled | bool | `true` |  |
| sentry.subscriptionConsumerEvents.env | list | `[]` |  |
| sentry.subscriptionConsumerEvents.livenessProbe.enabled | bool | `true` |  |
| sentry.subscriptionConsumerEvents.livenessProbe.initialDelaySeconds | int | `5` |  |
| sentry.subscriptionConsumerEvents.livenessProbe.periodSeconds | int | `320` |  |
| sentry.subscriptionConsumerEvents.nodeSelector | object | `{}` |  |
| sentry.subscriptionConsumerEvents.replicas | int | `1` |  |
| sentry.subscriptionConsumerEvents.resources | object | `{}` |  |
| sentry.subscriptionConsumerEvents.securityContext | object | `{}` |  |
| sentry.subscriptionConsumerEvents.sidecars | list | `[]` |  |
| sentry.subscriptionConsumerEvents.topologySpreadConstraints | list | `[]` |  |
| sentry.subscriptionConsumerEvents.volumes | list | `[]` |  |
| sentry.subscriptionConsumerGenericMetrics.affinity | object | `{}` |  |
| sentry.subscriptionConsumerGenericMetrics.containerSecurityContext | object | `{}` |  |
| sentry.subscriptionConsumerGenericMetrics.enabled | bool | `true` |  |
| sentry.subscriptionConsumerGenericMetrics.env | list | `[]` |  |
| sentry.subscriptionConsumerGenericMetrics.livenessProbe.enabled | bool | `true` |  |
| sentry.subscriptionConsumerGenericMetrics.livenessProbe.initialDelaySeconds | int | `5` |  |
| sentry.subscriptionConsumerGenericMetrics.livenessProbe.periodSeconds | int | `320` |  |
| sentry.subscriptionConsumerGenericMetrics.nodeSelector | object | `{}` |  |
| sentry.subscriptionConsumerGenericMetrics.replicas | int | `1` |  |
| sentry.subscriptionConsumerGenericMetrics.resources | object | `{}` |  |
| sentry.subscriptionConsumerGenericMetrics.securityContext | object | `{}` |  |
| sentry.subscriptionConsumerGenericMetrics.sidecars | list | `[]` |  |
| sentry.subscriptionConsumerGenericMetrics.topologySpreadConstraints | list | `[]` |  |
| sentry.subscriptionConsumerGenericMetrics.volumes | list | `[]` |  |
| sentry.subscriptionConsumerMetrics.affinity | object | `{}` |  |
| sentry.subscriptionConsumerMetrics.containerSecurityContext | object | `{}` |  |
| sentry.subscriptionConsumerMetrics.enabled | bool | `true` |  |
| sentry.subscriptionConsumerMetrics.env | list | `[]` |  |
| sentry.subscriptionConsumerMetrics.livenessProbe.enabled | bool | `true` |  |
| sentry.subscriptionConsumerMetrics.livenessProbe.initialDelaySeconds | int | `5` |  |
| sentry.subscriptionConsumerMetrics.livenessProbe.periodSeconds | int | `320` |  |
| sentry.subscriptionConsumerMetrics.nodeSelector | object | `{}` |  |
| sentry.subscriptionConsumerMetrics.replicas | int | `1` |  |
| sentry.subscriptionConsumerMetrics.resources | object | `{}` |  |
| sentry.subscriptionConsumerMetrics.securityContext | object | `{}` |  |
| sentry.subscriptionConsumerMetrics.sidecars | list | `[]` |  |
| sentry.subscriptionConsumerMetrics.topologySpreadConstraints | list | `[]` |  |
| sentry.subscriptionConsumerMetrics.volumes | list | `[]` |  |
| sentry.subscriptionConsumerSessions.affinity | object | `{}` |  |
| sentry.subscriptionConsumerSessions.containerSecurityContext | object | `{}` |  |
| sentry.subscriptionConsumerSessions.env | list | `[]` |  |
| sentry.subscriptionConsumerSessions.nodeSelector | object | `{}` |  |
| sentry.subscriptionConsumerSessions.replicas | int | `1` |  |
| sentry.subscriptionConsumerSessions.resources | object | `{}` |  |
| sentry.subscriptionConsumerSessions.securityContext | object | `{}` |  |
| sentry.subscriptionConsumerSessions.sidecars | list | `[]` |  |
| sentry.subscriptionConsumerSessions.topologySpreadConstraints | list | `[]` |  |
| sentry.subscriptionConsumerSessions.volumes | list | `[]` |  |
| sentry.subscriptionConsumerTransactions.affinity | object | `{}` |  |
| sentry.subscriptionConsumerTransactions.containerSecurityContext | object | `{}` |  |
| sentry.subscriptionConsumerTransactions.enabled | bool | `true` |  |
| sentry.subscriptionConsumerTransactions.env | list | `[]` |  |
| sentry.subscriptionConsumerTransactions.livenessProbe.enabled | bool | `true` |  |
| sentry.subscriptionConsumerTransactions.livenessProbe.initialDelaySeconds | int | `5` |  |
| sentry.subscriptionConsumerTransactions.livenessProbe.periodSeconds | int | `320` |  |
| sentry.subscriptionConsumerTransactions.nodeSelector | object | `{}` |  |
| sentry.subscriptionConsumerTransactions.replicas | int | `1` |  |
| sentry.subscriptionConsumerTransactions.resources | object | `{}` |  |
| sentry.subscriptionConsumerTransactions.securityContext | object | `{}` |  |
| sentry.subscriptionConsumerTransactions.sidecars | list | `[]` |  |
| sentry.subscriptionConsumerTransactions.topologySpreadConstraints | list | `[]` |  |
| sentry.subscriptionConsumerTransactions.volumes | list | `[]` |  |
| sentry.web.affinity | object | `{}` |  |
| sentry.web.autoscaling.enabled | bool | `false` |  |
| sentry.web.autoscaling.maxReplicas | int | `5` |  |
| sentry.web.autoscaling.minReplicas | int | `2` |  |
| sentry.web.autoscaling.targetCPUUtilizationPercentage | int | `50` |  |
| sentry.web.containerSecurityContext | object | `{}` |  |
| sentry.web.customResponseHeaders | list | `[]` |  |
| sentry.web.enabled | bool | `true` |  |
| sentry.web.env | list | `[]` |  |
| sentry.web.existingSecretEnv | list | `[]` |  |
| sentry.web.nodeSelector | object | `{}` |  |
| sentry.web.probeFailureThreshold | int | `5` |  |
| sentry.web.probeInitialDelaySeconds | int | `10` |  |
| sentry.web.probePeriodSeconds | int | `10` |  |
| sentry.web.probeSuccessThreshold | int | `1` |  |
| sentry.web.probeTimeoutSeconds | int | `2` |  |
| sentry.web.replicas | int | `1` |  |
| sentry.web.resources | object | `{}` |  |
| sentry.web.securityContext | object | `{}` |  |
| sentry.web.securityPolicy | string | `""` |  |
| sentry.web.service.annotations | object | `{}` |  |
| sentry.web.sidecars | list | `[]` |  |
| sentry.web.strategyType | string | `"RollingUpdate"` |  |
| sentry.web.topologySpreadConstraints | list | `[]` |  |
| sentry.web.volumeMounts | list | `[]` |  |
| sentry.web.volumes | list | `[]` |  |
| sentry.worker.affinity | object | `{}` |  |
| sentry.worker.autoscaling.enabled | bool | `false` |  |
| sentry.worker.autoscaling.maxReplicas | int | `5` |  |
| sentry.worker.autoscaling.minReplicas | int | `2` |  |
| sentry.worker.autoscaling.targetCPUUtilizationPercentage | int | `50` |  |
| sentry.worker.enabled | bool | `true` |  |
| sentry.worker.env | list | `[]` |  |
| sentry.worker.existingSecretEnv | list | `[]` |  |
| sentry.worker.livenessProbe.enabled | bool | `true` |  |
| sentry.worker.livenessProbe.failureThreshold | int | `3` |  |
| sentry.worker.livenessProbe.periodSeconds | int | `60` |  |
| sentry.worker.livenessProbe.timeoutSeconds | int | `10` |  |
| sentry.worker.nodeSelector | object | `{}` |  |
| sentry.worker.replicas | int | `1` |  |
| sentry.worker.resources | object | `{}` |  |
| sentry.worker.sidecars | list | `[]` |  |
| sentry.worker.topologySpreadConstraints | list | `[]` |  |
| sentry.worker.volumeMounts | list | `[]` |  |
| sentry.worker.volumes | list | `[]` |  |
| sentry.workerEvents.affinity | object | `{}` |  |
| sentry.workerEvents.autoscaling.enabled | bool | `false` |  |
| sentry.workerEvents.autoscaling.maxReplicas | int | `5` |  |
| sentry.workerEvents.autoscaling.minReplicas | int | `2` |  |
| sentry.workerEvents.autoscaling.targetCPUUtilizationPercentage | int | `50` |  |
| sentry.workerEvents.enabled | bool | `false` |  |
| sentry.workerEvents.env | list | `[]` |  |
| sentry.workerEvents.livenessProbe.enabled | bool | `false` |  |
| sentry.workerEvents.livenessProbe.failureThreshold | int | `3` |  |
| sentry.workerEvents.livenessProbe.periodSeconds | int | `60` |  |
| sentry.workerEvents.livenessProbe.timeoutSeconds | int | `10` |  |
| sentry.workerEvents.nodeSelector | object | `{}` |  |
| sentry.workerEvents.queues | string | `"events.save_event,post_process_errors"` |  |
| sentry.workerEvents.replicas | int | `1` |  |
| sentry.workerEvents.resources | object | `{}` |  |
| sentry.workerEvents.sidecars | list | `[]` |  |
| sentry.workerEvents.topologySpreadConstraints | list | `[]` |  |
| sentry.workerEvents.volumeMounts | list | `[]` |  |
| sentry.workerEvents.volumes | list | `[]` |  |
| sentry.workerTransactions.affinity | object | `{}` |  |
| sentry.workerTransactions.autoscaling.enabled | bool | `false` |  |
| sentry.workerTransactions.autoscaling.maxReplicas | int | `5` |  |
| sentry.workerTransactions.autoscaling.minReplicas | int | `2` |  |
| sentry.workerTransactions.autoscaling.targetCPUUtilizationPercentage | int | `50` |  |
| sentry.workerTransactions.enabled | bool | `false` |  |
| sentry.workerTransactions.env | list | `[]` |  |
| sentry.workerTransactions.livenessProbe.enabled | bool | `false` |  |
| sentry.workerTransactions.livenessProbe.failureThreshold | int | `3` |  |
| sentry.workerTransactions.livenessProbe.periodSeconds | int | `60` |  |
| sentry.workerTransactions.livenessProbe.timeoutSeconds | int | `10` |  |
| sentry.workerTransactions.nodeSelector | object | `{}` |  |
| sentry.workerTransactions.queues | string | `"events.save_event_transaction,post_process_transactions"` |  |
| sentry.workerTransactions.replicas | int | `1` |  |
| sentry.workerTransactions.resources | object | `{}` |  |
| sentry.workerTransactions.sidecars | list | `[]` |  |
| sentry.workerTransactions.topologySpreadConstraints | list | `[]` |  |
| sentry.workerTransactions.volumeMounts | list | `[]` |  |
| sentry.workerTransactions.volumes | list | `[]` |  |
| service.annotations | object | `{}` |  |
| service.externalPort | int | `9000` |  |
| service.name | string | `"sentry"` |  |
| service.type | string | `"ClusterIP"` |  |
| serviceAccount.annotations | object | `{}` | Additional Service Account annotations. |
| serviceAccount.automountServiceAccountToken | bool | `true` | Automount API credentials for a Service Account. |
| serviceAccount.enabled | bool | `false` | If `true`, a custom Service Account will be used. |
| serviceAccount.name | string | `"sentry"` | The base name of the ServiceAccount to use. Will be appended with e.g. `snuba-api` or `web` for the pods accordingly. |
| slack | object | `{}` |  |
| snuba.api.affinity | object | `{}` |  |
| snuba.api.autoscaling.enabled | bool | `false` |  |
| snuba.api.autoscaling.maxReplicas | int | `5` |  |
| snuba.api.autoscaling.minReplicas | int | `2` |  |
| snuba.api.autoscaling.targetCPUUtilizationPercentage | int | `50` |  |
| snuba.api.command | list | `[]` |  |
| snuba.api.containerSecurityContext | object | `{}` |  |
| snuba.api.enabled | bool | `true` |  |
| snuba.api.env | list | `[]` |  |
| snuba.api.liveness.timeoutSeconds | int | `2` |  |
| snuba.api.nodeSelector | object | `{}` |  |
| snuba.api.probeInitialDelaySeconds | int | `10` |  |
| snuba.api.readiness.timeoutSeconds | int | `2` |  |
| snuba.api.replicas | int | `1` |  |
| snuba.api.resources | object | `{}` |  |
| snuba.api.securityContext | object | `{}` |  |
| snuba.api.service.annotations | object | `{}` |  |
| snuba.api.sidecars | list | `[]` |  |
| snuba.api.topologySpreadConstraints | list | `[]` |  |
| snuba.api.volumes | list | `[]` |  |
| snuba.clickhouse.maxConnections | int | `100` |  |
| snuba.consumer.affinity | object | `{}` |  |
| snuba.consumer.autoOffsetReset | string | `"earliest"` |  |
| snuba.consumer.containerSecurityContext | object | `{}` |  |
| snuba.consumer.enabled | bool | `true` |  |
| snuba.consumer.env | list | `[]` |  |
| snuba.consumer.livenessProbe.enabled | bool | `true` |  |
| snuba.consumer.livenessProbe.initialDelaySeconds | int | `5` |  |
| snuba.consumer.livenessProbe.periodSeconds | int | `320` |  |
| snuba.consumer.maxBatchTimeMs | int | `750` |  |
| snuba.consumer.nodeSelector | object | `{}` |  |
| snuba.consumer.replicas | int | `1` |  |
| snuba.consumer.resources | object | `{}` |  |
| snuba.consumer.securityContext | object | `{}` |  |
| snuba.consumer.topologySpreadConstraints | list | `[]` |  |
| snuba.dbInitJob.env | list | `[]` |  |
| snuba.genericMetricsCountersConsumer.affinity | object | `{}` |  |
| snuba.genericMetricsCountersConsumer.autoOffsetReset | string | `"earliest"` |  |
| snuba.genericMetricsCountersConsumer.containerSecurityContext | object | `{}` |  |
| snuba.genericMetricsCountersConsumer.enabled | bool | `true` |  |
| snuba.genericMetricsCountersConsumer.env | list | `[]` |  |
| snuba.genericMetricsCountersConsumer.livenessProbe.enabled | bool | `true` |  |
| snuba.genericMetricsCountersConsumer.livenessProbe.initialDelaySeconds | int | `5` |  |
| snuba.genericMetricsCountersConsumer.livenessProbe.periodSeconds | int | `320` |  |
| snuba.genericMetricsCountersConsumer.maxBatchTimeMs | int | `750` |  |
| snuba.genericMetricsCountersConsumer.nodeSelector | object | `{}` |  |
| snuba.genericMetricsCountersConsumer.replicas | int | `1` |  |
| snuba.genericMetricsCountersConsumer.resources | object | `{}` |  |
| snuba.genericMetricsCountersConsumer.securityContext | object | `{}` |  |
| snuba.genericMetricsCountersConsumer.topologySpreadConstraints | list | `[]` |  |
| snuba.genericMetricsDistributionConsumer.affinity | object | `{}` |  |
| snuba.genericMetricsDistributionConsumer.autoOffsetReset | string | `"earliest"` |  |
| snuba.genericMetricsDistributionConsumer.containerSecurityContext | object | `{}` |  |
| snuba.genericMetricsDistributionConsumer.enabled | bool | `true` |  |
| snuba.genericMetricsDistributionConsumer.env | list | `[]` |  |
| snuba.genericMetricsDistributionConsumer.livenessProbe.enabled | bool | `true` |  |
| snuba.genericMetricsDistributionConsumer.livenessProbe.initialDelaySeconds | int | `5` |  |
| snuba.genericMetricsDistributionConsumer.livenessProbe.periodSeconds | int | `320` |  |
| snuba.genericMetricsDistributionConsumer.maxBatchTimeMs | int | `750` |  |
| snuba.genericMetricsDistributionConsumer.nodeSelector | object | `{}` |  |
| snuba.genericMetricsDistributionConsumer.replicas | int | `1` |  |
| snuba.genericMetricsDistributionConsumer.resources | object | `{}` |  |
| snuba.genericMetricsDistributionConsumer.securityContext | object | `{}` |  |
| snuba.genericMetricsDistributionConsumer.topologySpreadConstraints | list | `[]` |  |
| snuba.genericMetricsSetsConsumer.affinity | object | `{}` |  |
| snuba.genericMetricsSetsConsumer.autoOffsetReset | string | `"earliest"` |  |
| snuba.genericMetricsSetsConsumer.containerSecurityContext | object | `{}` |  |
| snuba.genericMetricsSetsConsumer.enabled | bool | `true` |  |
| snuba.genericMetricsSetsConsumer.env | list | `[]` |  |
| snuba.genericMetricsSetsConsumer.livenessProbe.enabled | bool | `true` |  |
| snuba.genericMetricsSetsConsumer.livenessProbe.initialDelaySeconds | int | `5` |  |
| snuba.genericMetricsSetsConsumer.livenessProbe.periodSeconds | int | `320` |  |
| snuba.genericMetricsSetsConsumer.maxBatchTimeMs | int | `750` |  |
| snuba.genericMetricsSetsConsumer.nodeSelector | object | `{}` |  |
| snuba.genericMetricsSetsConsumer.replicas | int | `1` |  |
| snuba.genericMetricsSetsConsumer.resources | object | `{}` |  |
| snuba.genericMetricsSetsConsumer.securityContext | object | `{}` |  |
| snuba.genericMetricsSetsConsumer.topologySpreadConstraints | list | `[]` |  |
| snuba.groupAttributesConsumer.affinity | object | `{}` |  |
| snuba.groupAttributesConsumer.autoOffsetReset | string | `"earliest"` |  |
| snuba.groupAttributesConsumer.containerSecurityContext | object | `{}` |  |
| snuba.groupAttributesConsumer.enabled | bool | `true` |  |
| snuba.groupAttributesConsumer.env | list | `[]` |  |
| snuba.groupAttributesConsumer.livenessProbe.enabled | bool | `true` |  |
| snuba.groupAttributesConsumer.livenessProbe.initialDelaySeconds | int | `5` |  |
| snuba.groupAttributesConsumer.livenessProbe.periodSeconds | int | `320` |  |
| snuba.groupAttributesConsumer.maxBatchTimeMs | int | `750` |  |
| snuba.groupAttributesConsumer.nodeSelector | object | `{}` |  |
| snuba.groupAttributesConsumer.replicas | int | `1` |  |
| snuba.groupAttributesConsumer.resources | object | `{}` |  |
| snuba.groupAttributesConsumer.securityContext | object | `{}` |  |
| snuba.groupAttributesConsumer.topologySpreadConstraints | list | `[]` |  |
| snuba.issueOccurrenceConsumer.affinity | object | `{}` |  |
| snuba.issueOccurrenceConsumer.autoOffsetReset | string | `"earliest"` |  |
| snuba.issueOccurrenceConsumer.containerSecurityContext | object | `{}` |  |
| snuba.issueOccurrenceConsumer.enabled | bool | `true` |  |
| snuba.issueOccurrenceConsumer.env | list | `[]` |  |
| snuba.issueOccurrenceConsumer.livenessProbe.enabled | bool | `true` |  |
| snuba.issueOccurrenceConsumer.livenessProbe.initialDelaySeconds | int | `5` |  |
| snuba.issueOccurrenceConsumer.livenessProbe.periodSeconds | int | `320` |  |
| snuba.issueOccurrenceConsumer.maxBatchTimeMs | int | `750` |  |
| snuba.issueOccurrenceConsumer.nodeSelector | object | `{}` |  |
| snuba.issueOccurrenceConsumer.replicas | int | `1` |  |
| snuba.issueOccurrenceConsumer.resources | object | `{}` |  |
| snuba.issueOccurrenceConsumer.securityContext | object | `{}` |  |
| snuba.issueOccurrenceConsumer.topologySpreadConstraints | list | `[]` |  |
| snuba.metricsConsumer.affinity | object | `{}` |  |
| snuba.metricsConsumer.autoOffsetReset | string | `"earliest"` |  |
| snuba.metricsConsumer.containerSecurityContext | object | `{}` |  |
| snuba.metricsConsumer.enabled | bool | `true` |  |
| snuba.metricsConsumer.env | list | `[]` |  |
| snuba.metricsConsumer.livenessProbe.enabled | bool | `true` |  |
| snuba.metricsConsumer.livenessProbe.initialDelaySeconds | int | `5` |  |
| snuba.metricsConsumer.livenessProbe.periodSeconds | int | `320` |  |
| snuba.metricsConsumer.maxBatchTimeMs | int | `750` |  |
| snuba.metricsConsumer.nodeSelector | object | `{}` |  |
| snuba.metricsConsumer.replicas | int | `1` |  |
| snuba.metricsConsumer.resources | object | `{}` |  |
| snuba.metricsConsumer.securityContext | object | `{}` |  |
| snuba.metricsConsumer.topologySpreadConstraints | list | `[]` |  |
| snuba.migrateJob.env | list | `[]` |  |
| snuba.outcomesBillingConsumer.affinity | object | `{}` |  |
| snuba.outcomesBillingConsumer.autoOffsetReset | string | `"earliest"` |  |
| snuba.outcomesBillingConsumer.containerSecurityContext | object | `{}` |  |
| snuba.outcomesBillingConsumer.enabled | bool | `true` |  |
| snuba.outcomesBillingConsumer.env | list | `[]` |  |
| snuba.outcomesBillingConsumer.livenessProbe.enabled | bool | `true` |  |
| snuba.outcomesBillingConsumer.livenessProbe.initialDelaySeconds | int | `5` |  |
| snuba.outcomesBillingConsumer.livenessProbe.periodSeconds | int | `320` |  |
| snuba.outcomesBillingConsumer.maxBatchSize | string | `"3"` |  |
| snuba.outcomesBillingConsumer.maxBatchTimeMs | int | `750` |  |
| snuba.outcomesBillingConsumer.nodeSelector | object | `{}` |  |
| snuba.outcomesBillingConsumer.replicas | int | `1` |  |
| snuba.outcomesBillingConsumer.resources | object | `{}` |  |
| snuba.outcomesBillingConsumer.securityContext | object | `{}` |  |
| snuba.outcomesBillingConsumer.topologySpreadConstraints | list | `[]` |  |
| snuba.outcomesConsumer.affinity | object | `{}` |  |
| snuba.outcomesConsumer.autoOffsetReset | string | `"earliest"` |  |
| snuba.outcomesConsumer.containerSecurityContext | object | `{}` |  |
| snuba.outcomesConsumer.enabled | bool | `true` |  |
| snuba.outcomesConsumer.env | list | `[]` |  |
| snuba.outcomesConsumer.livenessProbe.enabled | bool | `true` |  |
| snuba.outcomesConsumer.livenessProbe.initialDelaySeconds | int | `5` |  |
| snuba.outcomesConsumer.livenessProbe.periodSeconds | int | `320` |  |
| snuba.outcomesConsumer.maxBatchSize | string | `"3"` |  |
| snuba.outcomesConsumer.nodeSelector | object | `{}` |  |
| snuba.outcomesConsumer.replicas | int | `1` |  |
| snuba.outcomesConsumer.resources | object | `{}` |  |
| snuba.outcomesConsumer.securityContext | object | `{}` |  |
| snuba.outcomesConsumer.topologySpreadConstraints | list | `[]` |  |
| snuba.profilingFunctionsConsumer.affinity | object | `{}` |  |
| snuba.profilingFunctionsConsumer.autoOffsetReset | string | `"earliest"` |  |
| snuba.profilingFunctionsConsumer.containerSecurityContext | object | `{}` |  |
| snuba.profilingFunctionsConsumer.env | list | `[]` |  |
| snuba.profilingFunctionsConsumer.livenessProbe.enabled | bool | `true` |  |
| snuba.profilingFunctionsConsumer.livenessProbe.initialDelaySeconds | int | `5` |  |
| snuba.profilingFunctionsConsumer.livenessProbe.periodSeconds | int | `320` |  |
| snuba.profilingFunctionsConsumer.maxBatchTimeMs | int | `750` |  |
| snuba.profilingFunctionsConsumer.nodeSelector | object | `{}` |  |
| snuba.profilingFunctionsConsumer.replicas | int | `1` |  |
| snuba.profilingFunctionsConsumer.resources | object | `{}` |  |
| snuba.profilingFunctionsConsumer.securityContext | object | `{}` |  |
| snuba.profilingFunctionsConsumer.topologySpreadConstraints | list | `[]` |  |
| snuba.profilingProfilesConsumer.affinity | object | `{}` |  |
| snuba.profilingProfilesConsumer.autoOffsetReset | string | `"earliest"` |  |
| snuba.profilingProfilesConsumer.containerSecurityContext | object | `{}` |  |
| snuba.profilingProfilesConsumer.env | list | `[]` |  |
| snuba.profilingProfilesConsumer.livenessProbe.enabled | bool | `true` |  |
| snuba.profilingProfilesConsumer.livenessProbe.initialDelaySeconds | int | `5` |  |
| snuba.profilingProfilesConsumer.livenessProbe.periodSeconds | int | `320` |  |
| snuba.profilingProfilesConsumer.maxBatchTimeMs | int | `750` |  |
| snuba.profilingProfilesConsumer.nodeSelector | object | `{}` |  |
| snuba.profilingProfilesConsumer.replicas | int | `1` |  |
| snuba.profilingProfilesConsumer.resources | object | `{}` |  |
| snuba.profilingProfilesConsumer.securityContext | object | `{}` |  |
| snuba.profilingProfilesConsumer.topologySpreadConstraints | list | `[]` |  |
| snuba.replacer.affinity | object | `{}` |  |
| snuba.replacer.autoOffsetReset | string | `"earliest"` |  |
| snuba.replacer.containerSecurityContext | object | `{}` |  |
| snuba.replacer.enabled | bool | `true` |  |
| snuba.replacer.env | list | `[]` |  |
| snuba.replacer.nodeSelector | object | `{}` |  |
| snuba.replacer.replicas | int | `1` |  |
| snuba.replacer.resources | object | `{}` |  |
| snuba.replacer.securityContext | object | `{}` |  |
| snuba.replacer.topologySpreadConstraints | list | `[]` |  |
| snuba.replaysConsumer.affinity | object | `{}` |  |
| snuba.replaysConsumer.autoOffsetReset | string | `"earliest"` |  |
| snuba.replaysConsumer.containerSecurityContext | object | `{}` |  |
| snuba.replaysConsumer.enabled | bool | `true` |  |
| snuba.replaysConsumer.env | list | `[]` |  |
| snuba.replaysConsumer.livenessProbe.enabled | bool | `true` |  |
| snuba.replaysConsumer.livenessProbe.initialDelaySeconds | int | `5` |  |
| snuba.replaysConsumer.livenessProbe.periodSeconds | int | `320` |  |
| snuba.replaysConsumer.maxBatchTimeMs | int | `750` |  |
| snuba.replaysConsumer.nodeSelector | object | `{}` |  |
| snuba.replaysConsumer.replicas | int | `1` |  |
| snuba.replaysConsumer.resources | object | `{}` |  |
| snuba.replaysConsumer.securityContext | object | `{}` |  |
| snuba.replaysConsumer.topologySpreadConstraints | list | `[]` |  |
| snuba.rustConsumer | bool | `false` |  |
| snuba.sessionsConsumer.affinity | object | `{}` |  |
| snuba.sessionsConsumer.autoOffsetReset | string | `"earliest"` |  |
| snuba.sessionsConsumer.containerSecurityContext | object | `{}` |  |
| snuba.sessionsConsumer.env | list | `[]` |  |
| snuba.sessionsConsumer.nodeSelector | object | `{}` |  |
| snuba.sessionsConsumer.replicas | int | `1` |  |
| snuba.sessionsConsumer.resources | object | `{}` |  |
| snuba.sessionsConsumer.securityContext | object | `{}` |  |
| snuba.sessionsConsumer.topologySpreadConstraints | list | `[]` |  |
| snuba.spansConsumer.affinity | object | `{}` |  |
| snuba.spansConsumer.autoOffsetReset | string | `"earliest"` |  |
| snuba.spansConsumer.containerSecurityContext | object | `{}` |  |
| snuba.spansConsumer.enabled | bool | `true` |  |
| snuba.spansConsumer.env | list | `[]` |  |
| snuba.spansConsumer.livenessProbe.enabled | bool | `true` |  |
| snuba.spansConsumer.livenessProbe.initialDelaySeconds | int | `5` |  |
| snuba.spansConsumer.livenessProbe.periodSeconds | int | `320` |  |
| snuba.spansConsumer.maxBatchTimeMs | int | `750` |  |
| snuba.spansConsumer.nodeSelector | object | `{}` |  |
| snuba.spansConsumer.replicas | int | `1` |  |
| snuba.spansConsumer.resources | object | `{}` |  |
| snuba.spansConsumer.securityContext | object | `{}` |  |
| snuba.spansConsumer.topologySpreadConstraints | list | `[]` |  |
| snuba.subscriptionConsumerEvents.affinity | object | `{}` |  |
| snuba.subscriptionConsumerEvents.autoOffsetReset | string | `"earliest"` |  |
| snuba.subscriptionConsumerEvents.containerSecurityContext | object | `{}` |  |
| snuba.subscriptionConsumerEvents.enabled | bool | `true` |  |
| snuba.subscriptionConsumerEvents.env | list | `[]` |  |
| snuba.subscriptionConsumerEvents.livenessProbe.enabled | bool | `true` |  |
| snuba.subscriptionConsumerEvents.livenessProbe.initialDelaySeconds | int | `5` |  |
| snuba.subscriptionConsumerEvents.livenessProbe.periodSeconds | int | `320` |  |
| snuba.subscriptionConsumerEvents.nodeSelector | object | `{}` |  |
| snuba.subscriptionConsumerEvents.replicas | int | `1` |  |
| snuba.subscriptionConsumerEvents.resources | object | `{}` |  |
| snuba.subscriptionConsumerEvents.securityContext | object | `{}` |  |
| snuba.subscriptionConsumerEvents.topologySpreadConstraints | list | `[]` |  |
| snuba.subscriptionConsumerMetrics.affinity | object | `{}` |  |
| snuba.subscriptionConsumerMetrics.autoOffsetReset | string | `"earliest"` |  |
| snuba.subscriptionConsumerMetrics.containerSecurityContext | object | `{}` |  |
| snuba.subscriptionConsumerMetrics.enabled | bool | `true` |  |
| snuba.subscriptionConsumerMetrics.env | list | `[]` |  |
| snuba.subscriptionConsumerMetrics.livenessProbe.enabled | bool | `true` |  |
| snuba.subscriptionConsumerMetrics.livenessProbe.initialDelaySeconds | int | `5` |  |
| snuba.subscriptionConsumerMetrics.livenessProbe.periodSeconds | int | `320` |  |
| snuba.subscriptionConsumerMetrics.nodeSelector | object | `{}` |  |
| snuba.subscriptionConsumerMetrics.replicas | int | `1` |  |
| snuba.subscriptionConsumerMetrics.resources | object | `{}` |  |
| snuba.subscriptionConsumerMetrics.securityContext | object | `{}` |  |
| snuba.subscriptionConsumerMetrics.topologySpreadConstraints | list | `[]` |  |
| snuba.subscriptionConsumerSessions.affinity | object | `{}` |  |
| snuba.subscriptionConsumerSessions.autoOffsetReset | string | `"earliest"` |  |
| snuba.subscriptionConsumerSessions.containerSecurityContext | object | `{}` |  |
| snuba.subscriptionConsumerSessions.env | list | `[]` |  |
| snuba.subscriptionConsumerSessions.nodeSelector | object | `{}` |  |
| snuba.subscriptionConsumerSessions.replicas | int | `1` |  |
| snuba.subscriptionConsumerSessions.resources | object | `{}` |  |
| snuba.subscriptionConsumerSessions.securityContext | object | `{}` |  |
| snuba.subscriptionConsumerSessions.sidecars | list | `[]` |  |
| snuba.subscriptionConsumerSessions.topologySpreadConstraints | list | `[]` |  |
| snuba.subscriptionConsumerSessions.volumes | list | `[]` |  |
| snuba.subscriptionConsumerTransactions.affinity | object | `{}` |  |
| snuba.subscriptionConsumerTransactions.autoOffsetReset | string | `"earliest"` |  |
| snuba.subscriptionConsumerTransactions.containerSecurityContext | object | `{}` |  |
| snuba.subscriptionConsumerTransactions.enabled | bool | `true` |  |
| snuba.subscriptionConsumerTransactions.env | list | `[]` |  |
| snuba.subscriptionConsumerTransactions.livenessProbe.enabled | bool | `true` |  |
| snuba.subscriptionConsumerTransactions.livenessProbe.initialDelaySeconds | int | `5` |  |
| snuba.subscriptionConsumerTransactions.livenessProbe.periodSeconds | int | `320` |  |
| snuba.subscriptionConsumerTransactions.nodeSelector | object | `{}` |  |
| snuba.subscriptionConsumerTransactions.replicas | int | `1` |  |
| snuba.subscriptionConsumerTransactions.resources | object | `{}` |  |
| snuba.subscriptionConsumerTransactions.securityContext | object | `{}` |  |
| snuba.subscriptionConsumerTransactions.topologySpreadConstraints | list | `[]` |  |
| snuba.transactionsConsumer.affinity | object | `{}` |  |
| snuba.transactionsConsumer.autoOffsetReset | string | `"earliest"` |  |
| snuba.transactionsConsumer.containerSecurityContext | object | `{}` |  |
| snuba.transactionsConsumer.enabled | bool | `true` |  |
| snuba.transactionsConsumer.env | list | `[]` |  |
| snuba.transactionsConsumer.livenessProbe.enabled | bool | `true` |  |
| snuba.transactionsConsumer.livenessProbe.initialDelaySeconds | int | `5` |  |
| snuba.transactionsConsumer.livenessProbe.periodSeconds | int | `320` |  |
| snuba.transactionsConsumer.maxBatchTimeMs | int | `750` |  |
| snuba.transactionsConsumer.nodeSelector | object | `{}` |  |
| snuba.transactionsConsumer.replicas | int | `1` |  |
| snuba.transactionsConsumer.resources | object | `{}` |  |
| snuba.transactionsConsumer.securityContext | object | `{}` |  |
| snuba.transactionsConsumer.topologySpreadConstraints | list | `[]` |  |
| sourcemaps.enabled | bool | `false` |  |
| symbolicator.api.affinity | object | `{}` |  |
| symbolicator.api.autoscaling.enabled | bool | `false` |  |
| symbolicator.api.autoscaling.maxReplicas | int | `5` |  |
| symbolicator.api.autoscaling.minReplicas | int | `2` |  |
| symbolicator.api.autoscaling.targetCPUUtilizationPercentage | int | `50` |  |
| symbolicator.api.config | string | `"# See: https://getsentry.github.io/symbolicator/#configuration\ncache_dir: \"/data\"\nbind: \"0.0.0.0:3021\"\nlogging:\n  level: \"warn\"\nmetrics:\n  statsd: null\n  prefix: \"symbolicator\"\nsentry_dsn: null\nconnect_to_reserved_ips: true\n# caches:\n#   downloaded:\n#     max_unused_for: 1w\n#     retry_misses_after: 5m\n#     retry_malformed_after: 5m\n#   derived:\n#     max_unused_for: 1w\n#     retry_misses_after: 5m\n#     retry_malformed_after: 5m\n#   diagnostics:\n#     retention: 1w"` |  |
| symbolicator.api.containerSecurityContext | object | `{}` |  |
| symbolicator.api.env | list | `[]` |  |
| symbolicator.api.nodeSelector | object | `{}` |  |
| symbolicator.api.persistence.accessModes[0] | string | `"ReadWriteOnce"` |  |
| symbolicator.api.persistence.enabled | bool | `true` |  |
| symbolicator.api.persistence.size | string | `"10Gi"` |  |
| symbolicator.api.probeInitialDelaySeconds | int | `10` |  |
| symbolicator.api.replicas | int | `1` |  |
| symbolicator.api.resources | object | `{}` |  |
| symbolicator.api.securityContext | object | `{}` |  |
| symbolicator.api.topologySpreadConstraints | list | `[]` |  |
| symbolicator.api.usedeployment | bool | `true` |  |
| symbolicator.cleanup.enabled | bool | `false` |  |
| symbolicator.enabled | bool | `false` |  |
| system.adminEmail | string | `""` |  |
| system.public | bool | `false` |  |
| system.url | string | `""` |  |
| user.create | bool | `true` |  |
| user.email | string | `"admin@sentry.local"` |  |
| user.password | string | `"aaaa"` |  |
| vroom.affinity | object | `{}` |  |
| vroom.autoscaling.enabled | bool | `false` |  |
| vroom.autoscaling.maxReplicas | int | `5` |  |
| vroom.autoscaling.minReplicas | int | `2` |  |
| vroom.autoscaling.targetCPUUtilizationPercentage | int | `50` |  |
| vroom.containerSecurityContext | object | `{}` |  |
| vroom.env | list | `[]` |  |
| vroom.nodeSelector | object | `{}` |  |
| vroom.probeFailureThreshold | int | `5` |  |
| vroom.probeInitialDelaySeconds | int | `10` |  |
| vroom.probePeriodSeconds | int | `10` |  |
| vroom.probeSuccessThreshold | int | `1` |  |
| vroom.probeTimeoutSeconds | int | `2` |  |
| vroom.replicas | int | `1` |  |
| vroom.resources | object | `{}` |  |
| vroom.securityContext | object | `{}` |  |
| vroom.service.annotations | object | `{}` |  |
| vroom.sidecars | list | `[]` |  |
| vroom.volumeMounts | list | `[]` |  |
| vroom.volumes | list | `[]` |  |
| zookeeper.enabled | bool | `true` |  |
| zookeeper.nameOverride | string | `"zookeeper-clickhouse"` |  |
| zookeeper.replicaCount | int | `1` |  |

## NGINX and/or Ingress

By default, NGINX is enabled to allow sending the incoming requests to [Sentry Relay](https://getsentry.github.io/relay/) or the Django backend depending on the path. When Sentry is meant to be exposed outside of the Kubernetes cluster, it is recommended to disable NGINX and let the Ingress do the same. It's recommended to go with the go to Ingress Controller, [NGINX Ingress](https://kubernetes.github.io/ingress-nginx/) but others should work as well.

## Sentry secret key

If no `sentry.existingSecret` value is specified, for your security, the [`system.secret-key`](https://develop.sentry.dev/config/#general) is generated for you on the first installation and stored in a kubernetes secret.

If `sentry.existingSecret` / `sentry.existingSecretKey` values are provided, those secrets will be used.


## Symbolicator and or JavaScript source maps

For getting native stacktraces and minidumps symbolicated with debug symbols (e.g. iOS/Android), you need to enable Symbolicator via

```yaml
symbolicator:
  enabled: true
```

However, you also need to share the data between sentry-worker and sentry-web. This can be done in different ways:

- Using Cloud Storage like GCP GCS or AWS S3, see `filestore.backend` in `values.yaml`
- Using a filesystem like

```yaml
filestore:
  filesystem:
    persistence:
      persistentWorkers: true
      # storageClass: 'efs-storage' # see note below
```

Note: If you need to run or cannot avoid running sentry-worker and sentry-web on different cluster nodes, you need to set `filestore.filesystem.persistence.accessMode: ReadWriteMany` or might get problems. HOWEVER, [not all volume drivers support it](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#access-modes), like AWS EBS or GCP disks.
So you would want to create and use a `StorageClass` with a supported volume driver like [AWS EFS](https://github.com/kubernetes-sigs/aws-efs-csi-driver)

Its also important having `connect_to_reserved_ips: true` in the symbolicator config file, which this Chart defaults to.

#### Source Maps

To get javascript source map processing working, you need to activate sourcemaps, which in turn activates the memcached dependency:

```yaml
sourcemaps:
  enabled: true
```

For details on the background see this blog post: https://engblog.yext.com/post/sentry-js-source-maps


## Geolocation

[Geolocation of IP addresses](https://develop.sentry.dev/self-hosted/geolocation/) is supported if you provide a GeoIP database:

Example values.yaml:

```yaml

relay:
  # provide a volume for relay that contains the geoip database
  volumes:
    - name: geoip
      hostPath:
        path: /geodata
        type: Directory


sentry:
  web:
    # provide a volume for sentry-web that contains the geoip database
    volumes:
      - name: geoip
        hostPath:
          path: /geodata
          type: Directory

  worker:
    # provide a volume for sentry-worker that contains the geoip database
    volumes:
      - name: geoip
        hostPath:
          path: /geodata
          type: Directory


# enable and reference the volume
geodata:
  volumeName: geoip
  # mountPath of the volume containing the database
  mountPath: /geodata
  # path to the geoip database inside the volumemount
  path: /geodata/GeoLite2-City.mmdb
```

or

Warning:
storage must support ReadWriteMany

```yaml
# enable and reference the volume
geodata:
  accountID: "example"
  licenseKey: "example"
  editionIDs: "example"
  persistence:
    ## If defined, storageClassName: <storageClass>
    ## If undefined (the default) or set to null, no storageClassName spec is
    ##   set, choosing the default provisioner.  (gp2 on AWS, standard on
    ##   GKE, AWS & OpenStack)
    # storageClass: ""
    size: 1Gi
  volumeName: "data-sentry-geoip"
  # mountPath of the volume containing the database
  mountPath: "/usr/share/GeoIP"
  # path to the geoip database inside the volumemount
  path: "/usr/share/GeoIP/GeoLite2-City.mmdb"
```

## External Kafka configuration

You can either provide a single host, which is there by default in `values.yaml`, like this:

```yaml
externalKafka:
  ## Hostname or ip address of external kafka
  ##
  host: "kafka-confluent"
  port: 9092
```

or you can feed in a cluster of Kafka instances like below:

```yaml
externalKafka:
  cluster:
    ## List of Hostnames or ip addresses and ports of external kafka
    - host: "233.5.100.28"
      port: 9092
    - host: "kafka-confluent-2"
      port: 9093
    - host: "kafka-confluent-3"
      port: 9094
```

## External Postgres configuration

You can either pass postgres connection credentials directly in `values.yaml`:

```yaml
externalPostgresql:
  host: postgres
  port: 5432
  username: postgres
  password: postgres
  database: sentry
```

or use existing `secret` like in the example below:

```yaml
externalPostgresql:
  existingSecret: secret-name
  existingSecretKeys:
    password: password
    username: username
    database: database
    port: port
    host: host
```

it is possible to define which properties should be taken from secret or `values.yaml`, example below only takes `username` and `password` values from the secret:

```yaml
externalPostgresql:
  existingSecret: secret-name
  existingSecretKeys:
    password: password
    username: username
  port: 8000
  host: postgres
  database: sentry
```

> ⚠️ `.Values.externalPostgresql.existingSecretKey` is deprecated, `.Values.externalPostgresql.existingSecretKeys.password` should be used instead.

# Usage

- [AWS + Terraform](docs/usage-aws-terraform.md)
- [DigitalOcean](docs/usage-digitalocean.md)
