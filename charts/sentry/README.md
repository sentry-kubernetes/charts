# Install

## External Services

This chart relies on several external services for data storage and message brokering. While bundled versions are provided for testing and development, **production deployments should use external services**.

Currently, using an **external ClickHouse is a requirement** as the bundled version is deprecated.

Please refer to the [External Services Documentation](docs/external-services.md) for detailed setup instructions.

## Add repo

```
helm repo add sentry https://sentry-kubernetes.github.io/charts
```

## Quick install

You must provide an admin password (or reference an existing secret). For a quick test:

```
helm install sentry sentry/sentry --wait --timeout=1000s \
  --set user.password=CHANGE_ME
```

For production, create a Kubernetes secret and reference it via `user.existingSecret`:

```
kubectl create secret generic sentry-admin-password \
  --from-literal=admin-password='CHANGE_ME'

helm install sentry sentry/sentry --wait --timeout=1000s \
  --set user.existingSecret=sentry-admin-password
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
| clickhouse.nodeSelector | object | `{}` |  |
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
| filestore.profiles.backend | string | `"filesystem"` | Profiles storage backend (filesystem, gcs or s3). Recommended: object storage backend |
| filestore.profiles.gcs.secretName | string | `nil` | GCS service-account secret name for profiles storage. Must match filestore/replay GCS secret when shared in Sentry pods |
| filestore.profiles.gcs.credentialsFile | string | `nil` | Credentials filename inside the GCS secret for profiles storage. Must match filestore/replay GCS credentialsFile when shared in Sentry pods |
| filestore.profiles.gcs.bucketName | string | `nil` | GCS bucket name for profiles storage |
| filestore.profiles.s3.existingSecret | string | `nil` | Existing secret containing S3 credentials |
| filestore.profiles.s3.accessKeyIdRef | string | `nil` | Key in existingSecret for access key ID |
| filestore.profiles.s3.secretAccessKeyRef | string | `nil` | Key in existingSecret for secret access key |
| filestore.profiles.s3.access_key | string | `nil` | S3 access key (plain text) |
| filestore.profiles.s3.secret_key | string | `nil` | S3 secret key (plain text) |
| filestore.profiles.s3.bucket_name | string | `nil` | S3 bucket name for profiles |
| filestore.profiles.s3.endpoint_url | string | `nil` | S3 endpoint URL (for S3-compatible services like MinIO, SeaweedFS) |
| filestore.profiles.s3.signature_version | string | `nil` | S3 signature version (e.g. s3v4) |
| filestore.profiles.s3.region_name | string | `nil` | S3 region name |
| filestore.profiles.s3.default_acl | string | `nil` | Default ACL for S3 objects |
| filestore.profiles.s3.bucket_acl | string | `nil` | Bucket ACL for S3 |
| filestore.profiles.s3.addressing_style | string | `nil` | S3 addressing style (path or virtual) |
| filestore.profiles.filesystem.path | string | `"/var/lib/sentry/files/profiles"` | Path for filesystem profiles storage |
| filestore.profiles.filesystem.persistence.enabled | bool | `true` | Enable persistence for profiles filesystem storage |
| filestore.profiles.filesystem.persistence.shareWithVroom | bool | `false` | Share PVC with vroom deployment (requires ReadWriteMany on vroom.persistence.accessModes). NOT recommended for production |
| filestore.profiles.filesystem.persistence.accessModes[0] | string | `"ReadWriteOnce"` | Access mode for profiles PVC (use ReadWriteMany when shareWithVroom is true) |
| filestore.profiles.filesystem.persistence.size | string | `"10Gi"` | Size of profiles PVC |
| filestore.profiles.filesystem.persistence.existingClaim | string | `""` | Use existing PVC for profiles storage |
| filestore.profiles.filesystem.persistence.lookupVolumeName | bool | `true` | Lookup and use existing volume name |
| filestore.profiles.filesystem.persistence.storageClassName | string | `nil` | Storage class for profiles PVC |
| nodestore.backend | string | `""` | Node storage backend. Set to "s3" to enable S3-based node storage. Requires sentry-nodestore-s3 package (automatically installed via init containers) |
| nodestore.s3.existingSecret | string | `nil` | Existing secret containing S3 credentials for nodestore |
| nodestore.s3.accessKeyIdRef | string | `nil` | Key in existingSecret for access key ID |
| nodestore.s3.secretAccessKeyRef | string | `nil` | Key in existingSecret for secret access key |
| nodestore.s3.accessKeyId | string | `nil` | S3 access key ID (plain text) |
| nodestore.s3.secretAccessKey | string | `nil` | S3 secret access key (plain text) |
| nodestore.s3.bucketName | string | `nil` | S3 bucket name for nodestore |
| nodestore.s3.bucketPath | string | `nil` | S3 bucket path for nodestore |
| nodestore.s3.endpointUrl | string | `nil` | S3 endpoint URL (for S3-compatible services like MinIO, SeaweedFS) |
| nodestore.s3.regionName | string | `nil` | S3 region name for nodestore |
| nodestore.s3.compression | bool | `nil` | Enable compression for nodestore |
| geodata.accountID | string | `""` |  |
| geodata.editionIDs | string | `""` |  |
| geodata.licenseKey | string | `""` |  |
| geodata.mountPath | string | `""` |  |
| geodata.path | string | `""` |  |
| geodata.persistence.size | string | `"1Gi"` |  |
| geodata.volumeName | string | `""` |  |
| github | object | `{}` |  |
| global.nodeSelector | object | `{}` |  |
| global.sidecars | list | `[]` |  |
| global.tolerations | list | `[]` |  |
| global.volumeMounts | list | `[]` |  |
| global.volumes | list | `[]` |  |
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
| hooks.dbInit.resources.limits.memory | string | `"2560Mi"` |  |
| hooks.dbInit.resources.requests.cpu | string | `"300m"` |  |
| hooks.dbInit.resources.requests.memory | string | `"2048Mi"` |  |
| hooks.dbInit.sidecars | list | `[]` |  |
| hooks.dbInit.volumes | list | `[]` |  |
| hooks.enabled | bool | `true` |  |
| hooks.preUpgrade | bool | `false` |  |
| hooks.removeOnSuccess | bool | `true` |  |
| hooks.restartPolicy | string | `"Never"` |  |
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
| images.launchpad.imagePullSecrets | list | `[]` |  |
| ingress.annotations | object | `{"nginx.ingress.kubernetes.io/use-regex":"true","nginx.ingress.kubernetes.io/proxy-buffers-number":"4","nginx.ingress.kubernetes.io/proxy-buffer-size":"128k","nginx.ingress.kubernetes.io/proxy-busy-buffers-size":"256k"}` | Default ingress annotations (override per controller) |
| ingress.enabled | bool | `false` |  |
| ingress.ingressClassName | string | `"nginx"` |  |
| ingress.pathRules | object | `{"nginx":[...],"traefik":[...],"alb":[...],"gce":[...]}` | Controller-specific path rules (see values.yaml for defaults) |
| ingress.pathType | string | `"ImplementationSpecific"` |  |
| ingress.regexPathStyle | string | `""` | Controller style for path rules (auto from ingressClassName if empty) |
| ipv6 | bool | `false` |  |
| kafka.controller.nodeSelector | object | `{}` |  |
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
| kafka.provisioning.topics[10].name | string | `"outcomes-billing-dlq"` |  |
| kafka.provisioning.topics[11].name | string | `"ingest-sessions"` |  |
| kafka.provisioning.topics[12].config."cleanup.policy" | string | `"compact,delete"` |  |
| kafka.provisioning.topics[12].config."min.compaction.lag.ms" | string | `"3600000"` |  |
| kafka.provisioning.topics[12].name | string | `"snuba-metrics-commit-log"` |  |
| kafka.provisioning.topics[13].name | string | `"scheduled-subscriptions-events"` |  |
| kafka.provisioning.topics[14].name | string | `"scheduled-subscriptions-transactions"` |  |
| kafka.provisioning.topics[15].name | string | `"scheduled-subscriptions-metrics"` |  |
| kafka.provisioning.topics[16].name | string | `"scheduled-subscriptions-generic-metrics-sets"` |  |
| kafka.provisioning.topics[17].name | string | `"scheduled-subscriptions-generic-metrics-distributions"` |  |
| kafka.provisioning.topics[18].name | string | `"scheduled-subscriptions-generic-metrics-counters"` |  |
| kafka.provisioning.topics[19].name | string | `"scheduled-subscriptions-generic-metrics-gauges"` |  |
| kafka.provisioning.topics[1].name | string | `"event-replacements"` |  |
| kafka.provisioning.topics[20].name | string | `"events-subscription-results"` |  |
| kafka.provisioning.topics[21].name | string | `"transactions-subscription-results"` |  |
| kafka.provisioning.topics[22].name | string | `"metrics-subscription-results"` |  |
| kafka.provisioning.topics[23].name | string | `"generic-metrics-subscription-results"` |  |
| kafka.provisioning.topics[24].config."message.timestamp.type" | string | `"LogAppendTime"` |  |
| kafka.provisioning.topics[24].name | string | `"snuba-queries"` |  |
| kafka.provisioning.topics[25].config."message.timestamp.type" | string | `"LogAppendTime"` |  |
| kafka.provisioning.topics[25].name | string | `"processed-profiles"` |  |
| kafka.provisioning.topics[26].name | string | `"profiles-call-tree"` |  |
| kafka.provisioning.topics[27].name | string | `"snuba-profile-chunks"` |  |
| kafka.provisioning.topics[28].config."max.message.bytes" | string | `"15000000"` |  |
| kafka.provisioning.topics[28].config."message.timestamp.type" | string | `"LogAppendTime"` |  |
| kafka.provisioning.topics[28].name | string | `"ingest-replay-events"` |  |
| kafka.provisioning.topics[29].config."message.timestamp.type" | string | `"LogAppendTime"` |  |
| kafka.provisioning.topics[29].name | string | `"snuba-generic-metrics"` |  |
| kafka.provisioning.topics[2].config."cleanup.policy" | string | `"compact,delete"` |  |
| kafka.provisioning.topics[2].config."min.compaction.lag.ms" | string | `"3600000"` |  |
| kafka.provisioning.topics[2].name | string | `"snuba-commit-log"` |  |
| kafka.provisioning.topics[30].config."cleanup.policy" | string | `"compact,delete"` |  |
| kafka.provisioning.topics[30].config."min.compaction.lag.ms" | string | `"3600000"` |  |
| kafka.provisioning.topics[30].name | string | `"snuba-generic-metrics-sets-commit-log"` |  |
| kafka.provisioning.topics[31].config."cleanup.policy" | string | `"compact,delete"` |  |
| kafka.provisioning.topics[31].config."min.compaction.lag.ms" | string | `"3600000"` |  |
| kafka.provisioning.topics[31].name | string | `"snuba-generic-metrics-distributions-commit-log"` |  |
| kafka.provisioning.topics[32].config."cleanup.policy" | string | `"compact,delete"` |  |
| kafka.provisioning.topics[32].config."min.compaction.lag.ms" | string | `"3600000"` |  |
| kafka.provisioning.topics[32].name | string | `"snuba-generic-metrics-counters-commit-log"` |  |
| kafka.provisioning.topics[33].config."cleanup.policy" | string | `"compact,delete"` |  |
| kafka.provisioning.topics[33].config."min.compaction.lag.ms" | string | `"3600000"` |  |
| kafka.provisioning.topics[33].name | string | `"snuba-generic-metrics-gauges-commit-log"` |  |
| kafka.provisioning.topics[34].config."message.timestamp.type" | string | `"LogAppendTime"` |  |
| kafka.provisioning.topics[34].name | string | `"generic-events"` |  |
| kafka.provisioning.topics[35].config."cleanup.policy" | string | `"compact,delete"` |  |
| kafka.provisioning.topics[35].config."min.compaction.lag.ms" | string | `"3600000"` |  |
| kafka.provisioning.topics[35].name | string | `"snuba-generic-events-commit-log"` |  |
| kafka.provisioning.topics[36].config."message.timestamp.type" | string | `"LogAppendTime"` |  |
| kafka.provisioning.topics[36].name | string | `"group-attributes"` |  |
| kafka.provisioning.topics[37].name | string | `"snuba-dead-letter-metrics"` |  |
| kafka.provisioning.topics[38].name | string | `"snuba-dead-letter-generic-metrics"` |  |
| kafka.provisioning.topics[39].name | string | `"snuba-dead-letter-replays"` |  |
| kafka.provisioning.topics[3].name | string | `"cdc"` |  |
| kafka.provisioning.topics[40].name | string | `"snuba-dead-letter-generic-events"` |  |
| kafka.provisioning.topics[41].name | string | `"snuba-dead-letter-querylog"` |  |
| kafka.provisioning.topics[42].name | string | `"snuba-dead-letter-group-attributes"` |  |
| kafka.provisioning.topics[43].name | string | `"ingest-attachments"` |  |
| kafka.provisioning.topics[44].name | string | `"ingest-attachments-dlq"` |  |
| kafka.provisioning.topics[45].name | string | `"ingest-transactions"` |  |
| kafka.provisioning.topics[46].name | string | `"ingest-transactions-dlq"` |  |
| kafka.provisioning.topics[47].name | string | `"ingest-events-dlq"` |  |
| kafka.provisioning.topics[48].name | string | `"ingest-events"` |  |
| kafka.provisioning.topics[49].name | string | `"ingest-replay-recordings"` |  |
| kafka.provisioning.topics[4].config."message.timestamp.type" | string | `"LogAppendTime"` |  |
| kafka.provisioning.topics[4].name | string | `"transactions"` |  |
| kafka.provisioning.topics[50].name | string | `"ingest-metrics"` |  |
| kafka.provisioning.topics[51].name | string | `"ingest-metrics-dlq"` |  |
| kafka.provisioning.topics[52].name | string | `"ingest-performance-metrics"` |  |
| kafka.provisioning.topics[53].name | string | `"ingest-feedback-events"` |  |
| kafka.provisioning.topics[54].name | string | `"ingest-feedback-events-dlq"` |  |
| kafka.provisioning.topics[55].name | string | `"ingest-monitors"` |  |
| kafka.provisioning.topics[56].name | string | `"monitors-clock-tasks"` |  |
| kafka.provisioning.topics[57].name | string | `"monitors-clock-tick"` |  |
| kafka.provisioning.topics[58].name | string | `"monitors-incident-occurrences"` |  |
| kafka.provisioning.topics[59].name | string | `"profiles"` |  |
| kafka.provisioning.topics[5].config."cleanup.policy" | string | `"compact,delete"` |  |
| kafka.provisioning.topics[5].config."min.compaction.lag.ms" | string | `"3600000"` |  |
| kafka.provisioning.topics[5].name | string | `"snuba-transactions-commit-log"` |  |
| kafka.provisioning.topics[60].name | string | `"ingest-occurrences"` |  |
| kafka.provisioning.topics[61].name | string | `"snuba-spans"` |  |
| kafka.provisioning.topics[62].name | string | `"snuba-eap-spans-commit-log"` |  |
| kafka.provisioning.topics[63].name | string | `"scheduled-subscriptions-eap-spans"` |  |
| kafka.provisioning.topics[64].name | string | `"eap-spans-subscription-results"` |  |
| kafka.provisioning.topics[65].name | string | `"snuba-eap-mutations"` |  |
| kafka.provisioning.topics[66].name | string | `"snuba-lw-deletions-generic-events"` |  |
| kafka.provisioning.topics[67].name | string | `"shared-resources-usage"` |  |
| kafka.provisioning.topics[68].name | string | `"snuba-profile-chunks"` |  |
| kafka.provisioning.topics[69].name | string | `"buffered-segments"` |  |
| kafka.provisioning.topics[6].config."message.timestamp.type" | string | `"LogAppendTime"` |  |
| kafka.provisioning.topics[6].name | string | `"snuba-metrics"` |  |
| kafka.provisioning.topics[70].name | string | `"buffered-segments-dlq"` |  |
| kafka.provisioning.topics[71].name | string | `"uptime-configs"` |  |
| kafka.provisioning.topics[72].name | string | `"uptime-results"` |  |
| kafka.provisioning.topics[73].name | string | `"task-worker"` |  |
| kafka.provisioning.topics[7].name | string | `"outcomes"` |  |
| kafka.provisioning.topics[8].name | string | `"outcomes-dlq"` |  |
| kafka.provisioning.topics[9].name | string | `"outcomes-billing"` |  |
| kafka.sasl.client.users | list | `[]` | List of usernames for client communications when SASL is enabled, first user will be used if enabled |
| kafka.sasl.client.passwords | list | `[]` | List of passwords for client communications when SASL is enabled, must match the number of client.users, first password will be used if enabled |
| kafka.sasl.enabledMechanisms | string | `"PLAIN,SCRAM-SHA-256,SCRAM-SHA-512"` | Comma-separated list of allowed SASL mechanisms when SASL listeners are configured |
| mail.backend | string | `"dummy"` |  |
| mail.from | string | `""` |  |
| mail.host | string | `""` |  |
| mail.password | string | `""` |  |
| mail.port | int | `25` |  |
| mail.useSsl | bool | `false` |  |
| mail.useTls | bool | `false` |  |
| mail.username | string | `""` |  |
| memcached.config.extraArgs[0] | string | `"-I"` |  |
| memcached.config.extraArgs[1] | string | `"26214400"` |  |
| memcached.config.memoryLimit | int | `2048` |  |
| memcached.config.verbosity | int | `1` |  |
| memcached.nodeSelector | object | `{}` |  |
| memcached.tolerations | list | `[]` |  |
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
| metrics.readinessProbe.failureThreshold | int | `2` |  |
| metrics.readinessProbe.initialDelaySeconds | int | `30` |  |
| metrics.readinessProbe.periodSeconds | int | `3` |  |
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
| metrics.sidecars | list | `[]` |  |
| metrics.tolerations | list | `[]` |  |
| metrics.volumes | list | `[]` |  |
| nginx.containerPort | int | `8080` |  |
| nginx.customReadinessProbe.failureThreshold | int | `3` |  |
| nginx.customReadinessProbe.initialDelaySeconds | int | `5` |  |
| nginx.customReadinessProbe.periodSeconds | int | `5` |  |
| nginx.customReadinessProbe.successThreshold | int | `1` |  |
| nginx.customReadinessProbe.tcpSocket.port | string | `"http"` |  |
| nginx.customReadinessProbe.timeoutSeconds | int | `3` |  |
| nginx.enabled | bool | `false` |  |
| nginx.existingServerConfigConfigmap | string | `"{{ template \"sentry.fullname\" . }}"` |  |
| nginx.extraLocationSnippet | bool | `false` |  |
| openai | object | `{}` |  |
| pagerduty | object | `{}` |  |
| pgbouncer.affinity | object | `{}` |  |
| pgbouncer.authType | string | `"md5"` |  |
| pgbouncer.enabled | bool | `false` |  |
| pgbouncer.image.pullPolicy | string | `"IfNotPresent"` |  |
| pgbouncer.image.repository | string | `"bitnami/pgbouncer"` |  |
| pgbouncer.image.tag | string | `"1.23.1-debian-12-r5"` |  |
| pgbouncer.maxClientConn | string | `"8192"` |  |
| pgbouncer.nodeSelector | object | `{}` |  |
| pgbouncer.podDisruptionBudget.enabled | bool | `true` |  |
| pgbouncer.podDisruptionBudget.minAvailable | int | `1` |  |
| pgbouncer.poolMode | string | `"transaction"` |  |
| pgbouncer.poolSize | string | `"50"` |  |
| pgbouncer.postgres.cp_max | int | `10` |  |
| pgbouncer.postgres.cp_min | int | `5` |  |
| pgbouncer.postgres.dbname | string | `""` |  |
| pgbouncer.postgres.host | string | `""` |  |
| pgbouncer.postgres.password | string | `""` |  |
| pgbouncer.postgres.user | string | `""` |  |
| pgbouncer.priorityClassName | string | `""` |  |
| pgbouncer.replicas | int | `2` |  |
| pgbouncer.resources | object | `{}` |  |
| pgbouncer.tolerations | list | `[]` |  |
| pgbouncer.topologySpreadConstraints | list | `[]` |  |
| pgbouncer.updateStrategy.rollingUpdate.maxSurge | string | `"25%"` |  |
| pgbouncer.updateStrategy.rollingUpdate.maxUnavailable | int | `1` |  |
| pgbouncer.updateStrategy.type | string | `"RollingUpdate"` |  |
| postgresql.auth.database | string | `"sentry"` |  |
| postgresql.connMaxAge | int | `0` |  |
| postgresql.enabled | bool | `true` |  |
| postgresql.nameOverride | string | `"sentry-postgresql"` |  |
| postgresql.replication.applicationName | string | `"sentry"` |  |
| postgresql.replication.enabled | bool | `false` |  |
| postgresql.replication.numSynchronousReplicas | int | `1` |  |
| postgresql.replication.readReplicas | int | `2` |  |
| postgresql.replication.synchronousCommit | string | `"on"` |  |
| redis.auth.enabled | bool | `false` |  |
| redis.auth.sentinel | bool | `false` |  |
| redis.enabled | bool | `true` |  |
| redis.master.nodeSelector | object | `{}` |  |
| redis.master.persistence.enabled | bool | `true` |  |
| redis.nameOverride | string | `"sentry-redis"` |  |
| redis.replica.nodeSelector | object | `{}` |  |
| redis.replica.replicaCount | int | `1` |  |
| relay.affinity | object | `{}` |  |
| relay.asHook | bool | `true` | Deploy relay as a Helm hook. Set to false for rolling updates instead of delete-and-recreate on upgrades |
| relay.autoscaling.enabled | bool | `false` |  |
| relay.autoscaling.maxReplicas | int | `5` |  |
| relay.autoscaling.minReplicas | int | `2` |  |
| relay.autoscaling.targetCPUUtilizationPercentage | int | `50` |  |
| relay.configRender.image.pullPolicy | string | `"IfNotPresent"` |  |
| relay.configRender.image.repository | string | `"busybox"` |  |
| relay.configRender.image.tag | string | `"1.36"` |  |
| relay.containerSecurityContext | object | `{}` |  |
| relay.customResponseHeaders | list | `[]` |  |
| relay.enabled | bool | `true` |  |
| relay.env | list | `[]` |  |
| relay.init.resources | object | `{}` |  |
| relay.mode | string | `"managed"` |  |
| relay.livenessProbe.failureThreshold | int | `5` |  |
| relay.livenessProbe.initialDelaySeconds | int | `10` |  |
| relay.livenessProbe.periodSeconds | int | `10` |  |
| relay.livenessProbe.successThreshold | int | `1` |  |
| relay.livenessProbe.timeoutSeconds | int | `2` |  |
| relay.nodeSelector | object | `{}` |  |
| relay.processing.kafkaConfig.messageMaxBytes | int | `50000000` |  |
| relay.readinessProbe.failureThreshold | int | `2` |  |
| relay.readinessProbe.initialDelaySeconds | int | `10` |  |
| relay.readinessProbe.periodSeconds | int | `3` |  |
| relay.readinessProbe.successThreshold | int | `1` |  |
| relay.readinessProbe.timeoutSeconds | int | `2` |  |
| relay.replicas | int | `1` |  |
| relay.resources | object | `{}` |  |
| relay.securityContext | object | `{}` |  |
| relay.securityPolicy | string | `""` |  |
| relay.service.annotations | object | `{}` |  |
| relay.sidecars | list | `[]` |  |
| relay.topologySpreadConstraints | list | `[]` |  |
| relay.volumeMounts | list | `[]` |  |
| relay.volumes | list | `[]` |  |
| route.httpRedirect.annotations | object | `{}` | Annotations for the HTTP redirect HTTPRoute |
| route.httpRedirect.apiVersion | string | `"gateway.networking.k8s.io/v1"` | API version for HTTPRoute (auto-detected if not set) |
| route.httpRedirect.enabled | bool | `false` | Enable HTTP to HTTPS redirect HTTPRoute |
| route.httpRedirect.hostnames | list | `[]` | Hostnames (inherits from main route if empty) |
| route.httpRedirect.kind | string | `"HTTPRoute"` | Route kind |
| route.httpRedirect.labels | object | `{}` | Labels for the HTTP redirect HTTPRoute |
| route.httpRedirect.parentRefs | list | `[]` | Parent Gateway references for HTTP listener |
| route.httpRedirect.statusCode | int | `301` | HTTP redirect status code (301=permanent, 302=temporary) |
| route.main.additionalRules | list | `[]` | Additional custom rules to prepend |
| route.main.annotations | object | `{}` | Annotations for the HTTPRoute |
| route.main.apiVersion | string | `"gateway.networking.k8s.io/v1"` | API version for HTTPRoute (auto-detected if not set) |
| route.main.enabled | bool | `false` | Enable Gateway API HTTPRoute |
| route.main.filters | list | `[]` | Filters applied to all backend requests |
| route.main.hostnames | list | `[]` | Hostnames for the HTTPRoute |
| route.main.kind | string | `"HTTPRoute"` | Route kind (HTTPRoute, GRPCRoute, etc.) |
| route.main.labels | object | `{}` | Labels for the HTTPRoute |
| route.main.parentRefs | list | `[]` | Parent Gateway references (required when enabled) |
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
| sentry.billingMetricsConsumer.maxPollIntervalMs | int | `300000` | Kafka `--max-poll-interval-ms` (self-hosted `SENTRY_KAFKA_MAX_POLL_INTERVAL_MS`). Set `null` to omit the flag. |
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
| sentry.genericMetricsConsumer.maxPollIntervalMs | int | `300000` | Kafka `--max-poll-interval-ms` (self-hosted `SENTRY_KAFKA_MAX_POLL_INTERVAL_MS`). Set `null` to omit the flag. |
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
| sentry.ingestConsumerAttachments.maxPollIntervalMs | int | `300000` | Kafka `--max-poll-interval-ms` (self-hosted `SENTRY_KAFKA_MAX_POLL_INTERVAL_MS`). Set `null` to omit the flag. |
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
| sentry.ingestConsumerEvents.maxPollIntervalMs | int | `300000` | Kafka `--max-poll-interval-ms` (self-hosted `SENTRY_KAFKA_MAX_POLL_INTERVAL_MS`). Set `null` to omit the flag. |
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
| sentry.ingestConsumerTransactions.maxPollIntervalMs | int | `300000` | Kafka `--max-poll-interval-ms` (self-hosted `SENTRY_KAFKA_MAX_POLL_INTERVAL_MS`). Set `null` to omit the flag. |
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
| sentry.ingestFeedback.enabled | bool | `false` |  |
| sentry.ingestFeedback.env | list | `[]` |  |
| sentry.ingestFeedback.livenessProbe.enabled | bool | `true` |  |
| sentry.ingestFeedback.livenessProbe.initialDelaySeconds | int | `5` |  |
| sentry.ingestFeedback.livenessProbe.periodSeconds | int | `320` |  |
| sentry.ingestFeedback.maxPollIntervalMs | int | `300000` | Kafka `--max-poll-interval-ms` (self-hosted `SENTRY_KAFKA_MAX_POLL_INTERVAL_MS`). Set `null` to omit the flag. |
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
| sentry.ingestMonitors.maxPollIntervalMs | int | `300000` | Kafka `--max-poll-interval-ms` (self-hosted `SENTRY_KAFKA_MAX_POLL_INTERVAL_MS`). Set `null` to omit the flag. |
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
| sentry.ingestOccurrences.maxPollIntervalMs | int | `300000` | Kafka `--max-poll-interval-ms` (self-hosted `SENTRY_KAFKA_MAX_POLL_INTERVAL_MS`). Set `null` to omit the flag. |
| sentry.ingestOccurrences.nodeSelector | object | `{}` |  |
| sentry.ingestOccurrences.replicas | int | `1` |  |
| sentry.ingestOccurrences.resources | object | `{}` |  |
| sentry.ingestOccurrences.securityContext | object | `{}` |  |
| sentry.ingestOccurrences.sidecars | list | `[]` |  |
| sentry.ingestOccurrences.topologySpreadConstraints | list | `[]` |  |
| sentry.ingestOccurrences.volumes | list | `[]` |  |
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
| sentry.ingestReplayRecordings.maxPollIntervalMs | int | `300000` | Kafka `--max-poll-interval-ms` (self-hosted `SENTRY_KAFKA_MAX_POLL_INTERVAL_MS`). Set `null` to omit the flag. |
| sentry.ingestReplayRecordings.nodeSelector | object | `{}` |  |
| sentry.ingestReplayRecordings.replicas | int | `1` |  |
| sentry.ingestReplayRecordings.resources | object | `{}` |  |
| sentry.ingestReplayRecordings.securityContext | object | `{}` |  |
| sentry.ingestReplayRecordings.sidecars | list | `[]` |  |
| sentry.ingestReplayRecordings.topologySpreadConstraints | list | `[]` |  |
| sentry.ingestReplayRecordings.volumes | list | `[]` |  |
| sentry.kafka.compression.type | string | `""` | Compression type for Kafka messages |
| sentry.kafka.message.max.bytes | int | `50000000` | Maximum message size for Kafka |
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
| sentry.metricsConsumer.maxPollIntervalMs | int | `300000` | Kafka `--max-poll-interval-ms` (self-hosted `SENTRY_KAFKA_MAX_POLL_INTERVAL_MS`). Set `null` to omit the flag. |
| sentry.metricsConsumer.nodeSelector | object | `{}` |  |
| sentry.metricsConsumer.replicas | int | `1` |  |
| sentry.metricsConsumer.resources | object | `{}` |  |
| sentry.metricsConsumer.securityContext | object | `{}` |  |
| sentry.metricsConsumer.sidecars | list | `[]` |  |
| sentry.metricsConsumer.topologySpreadConstraints | list | `[]` |  |
| sentry.metricsConsumer.volumes | list | `[]` |  |
| sentry.monitorsClockTasks.maxPollIntervalMs | int | `300000` | Kafka `--max-poll-interval-ms` (self-hosted `SENTRY_KAFKA_MAX_POLL_INTERVAL_MS`). Set `null` to omit the flag. |
| sentry.monitorsClockTick.maxPollIntervalMs | int | `300000` | Kafka `--max-poll-interval-ms` (self-hosted `SENTRY_KAFKA_MAX_POLL_INTERVAL_MS`). Set `null` to omit the flag. |
| sentry.postProcessForwardErrors.affinity | object | `{}` |  |
| sentry.postProcessForwardErrors.containerSecurityContext | object | `{}` |  |
| sentry.postProcessForwardErrors.enabled | bool | `true` |  |
| sentry.postProcessForwardErrors.env | list | `[]` |  |
| sentry.postProcessForwardErrors.livenessProbe.enabled | bool | `true` |  |
| sentry.postProcessForwardErrors.livenessProbe.initialDelaySeconds | int | `5` |  |
| sentry.postProcessForwardErrors.livenessProbe.periodSeconds | int | `320` |  |
| sentry.postProcessForwardErrors.maxPollIntervalMs | int | `300000` | Kafka `--max-poll-interval-ms` (self-hosted `SENTRY_KAFKA_MAX_POLL_INTERVAL_MS`). Set `null` to omit the flag. |
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
| sentry.postProcessForwardIssuePlatform.maxPollIntervalMs | int | `300000` | Kafka `--max-poll-interval-ms` (self-hosted `SENTRY_KAFKA_MAX_POLL_INTERVAL_MS`). Set `null` to omit the flag. |
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
| sentry.postProcessForwardTransactions.maxPollIntervalMs | int | `300000` | Kafka `--max-poll-interval-ms` (self-hosted `SENTRY_KAFKA_MAX_POLL_INTERVAL_MS`). Set `null` to omit the flag. |
| sentry.postProcessForwardTransactions.nodeSelector | object | `{}` |  |
| sentry.postProcessForwardTransactions.replicas | int | `1` |  |
| sentry.postProcessForwardTransactions.resources | object | `{}` |  |
| sentry.postProcessForwardTransactions.securityContext | object | `{}` |  |
| sentry.postProcessForwardTransactions.sidecars | list | `[]` |  |
| sentry.postProcessForwardTransactions.topologySpreadConstraints | list | `[]` |  |
| sentry.postProcessForwardTransactions.volumes | list | `[]` |  |
| sentry.processSegments.maxPollIntervalMs | int | `300000` | Kafka `--max-poll-interval-ms` (self-hosted `SENTRY_KAFKA_MAX_POLL_INTERVAL_MS`). Set `null` to omit the flag. |
| sentry.processSpans.maxPollIntervalMs | int | `300000` | Kafka `--max-poll-interval-ms` (self-hosted `SENTRY_KAFKA_MAX_POLL_INTERVAL_MS`). Set `null` to omit the flag. |
| sentry.singleOrganization | bool | `true` |  |
| sentry.taskBroker.affinity | object | `{}` | |
| sentry.taskBroker.brokers | list | (see `values.yaml`) | One broker StatefulSet per item. Required per broker: `name`, `kafkaDeadletterTopic`, `kafkaRetryTopic`, `kafkaTopics` (YAML map mounted at `/etc/taskbroker/config.yml`; hyphenated topic names need YAML, not env). Optional: `replicas`, `resources` (merged with `sentry.taskBroker.resources`), `topologySpreadConstraints` (overrides `sentry.taskBroker.topologySpreadConstraints`). Replaces legacy `topic` / `consumerGroup`. See [taskbroker Kafka config migration](https://github.com/getsentry/taskbroker/blob/main/docs/kafka-config-migration.md). |
| sentry.taskBroker.containerSecurityContext | object | `{}` | |
| sentry.taskBroker.enabled | bool | `true` | |
| sentry.taskBroker.env | list | `[]` | |
| sentry.taskBroker.nodeSelector | object | `{}` | |
| sentry.taskBroker.persistence.accessMode | string | `"ReadWriteOnce"` | |
| sentry.taskBroker.persistence.enabled | bool | `true` | |
| sentry.taskBroker.persistence.size | string | `"1Gi"` | |
| sentry.taskBroker.persistence.storageClass | string | `""` | |
| sentry.taskBroker.priorityClassName | string | `""` | |
| sentry.taskBroker.replicas | int | `1` | |
| sentry.taskBroker.resources | object | `{}` | Default container resources for task broker pods; merged with each broker’s `resources` in `sentry.taskBroker.brokers`. |
| sentry.taskBroker.securityContext | object | `{}` | |
| sentry.taskBroker.sidecars | list | `[]` | |
| sentry.taskBroker.tolerations | list | `[]` | |
| sentry.taskBroker.topologySpreadConstraints | list | `[]` | Default pod topologySpreadConstraints for task broker pods; overridden by each broker’s `topologySpreadConstraints` in `sentry.taskBroker.brokers`. |
| sentry.taskBroker.volumeMounts | list | `[]` | |
| sentry.taskBroker.volumes | list | `[]` | |
| sentry.taskWorker.affinity | object | `{}` | |
| sentry.taskWorker.autoscaling.enabled | bool | `false` | |
| sentry.taskWorker.autoscaling.maxReplicas | int | `5` | |
| sentry.taskWorker.autoscaling.minReplicas | int | `1` | |
| sentry.taskWorker.autoscaling.targetCPUUtilizationPercentage | int | `50` | |
| sentry.taskWorker.concurrency | int | `4` | |
| sentry.taskWorker.containerSecurityContext | object | `{}` | |
| sentry.taskWorker.enabled | bool | `true` | |
| sentry.taskWorker.env | list | `[]` | |
| sentry.taskWorker.livenessProbe.initialDelaySeconds | int | `10` | |
| sentry.taskWorker.livenessProbe.periodSeconds | int | `10` | |
| sentry.taskWorker.livenessProbe.timeoutSeconds | int | `5` | |
| sentry.taskWorker.nodeSelector | object | `{}` | |
| sentry.taskWorker.priorityClassName | string | `""` | |
| sentry.taskWorker.replicas | int | `1` | |
| sentry.taskWorker.resources | object | `{}` | Default container resources for task worker pods; merged with each worker’s `resources` in `sentry.taskWorker.workers`. |
| sentry.taskWorker.securityContext | object | `{}` | |
| sentry.taskWorker.sidecars | list | `[]` | |
| sentry.taskWorker.tolerations | list | `[]` | |
| sentry.taskWorker.topologySpreadConstraints | list | `[]` | Default pod topologySpreadConstraints for task worker pods; overriden by each worker’s `topologySpreadConstraints` in `sentry.taskWorker.workers`. |
| sentry.taskWorker.volumeMounts | list | `[]` | |
| sentry.taskWorker.volumes | list | `[]` | |
| sentry.taskWorker.workers | list | (see `values.yaml`) | One task worker Deployment per item (`name`, `brokerName`, `brokerReplicas`, `replicas`, `concurrency`, optional `resources` merged with `sentry.taskWorker.resources`, optional `autoscaling` overriding `sentry.taskWorker.autoscaling`, optional `topologySpreadConstraints` overriding `sentry.taskWorker.topologySpreadConstraints`). |
| launchpadTaskWorker.enabled | bool | `true` | Deploy Launchpad taskworker (mobile build processing). Requires `feature-complete` profile and `sentry.taskBroker.enabled`. |
| launchpadTaskWorker.replicas | int | `1` |  |
| launchpadTaskWorker.concurrency | int | `4` | Parallel Launchpad worker processes (`LAUNCHPAD_WORKER_CONCURRENCY`). |
| launchpadTaskWorker.env | list | `[]` | Extra environment variables for the Launchpad taskworker container. |
| launchpadTaskWorker.resources | object | `{}` |  |
| launchpadTaskWorker.affinity | object | `{}` |  |
| launchpadTaskWorker.nodeSelector | object | `{}` |  |
| launchpadTaskWorker.securityContext | object | `{}` |  |
| launchpadTaskWorker.containerSecurityContext | object | `{}` |  |
| launchpadTaskWorker.tolerations | list | `[]` |  |
| launchpadTaskWorker.podLabels | object | `{}` |  |
| launchpadTaskWorker.livenessProbe.initialDelaySeconds | int | `30` |  |
| launchpadTaskWorker.livenessProbe.periodSeconds | int | `10` |  |
| launchpadTaskWorker.livenessProbe.timeoutSeconds | int | `5` |  |
| sentry.uptimeResults.maxPollIntervalMs | int | `300000` | Kafka `--max-poll-interval-ms` (self-hosted `SENTRY_KAFKA_MAX_POLL_INTERVAL_MS`). Set `null` to omit the flag. |
| sentry.web.affinity | object | `{}` |  |
| sentry.web.autoscaling.enabled | bool | `false` |  |
| sentry.web.autoscaling.maxReplicas | int | `5` |  |
| sentry.web.autoscaling.minReplicas | int | `2` |  |
| sentry.web.autoscaling.targetCPUUtilizationPercentage | int | `50` |  |
| sentry.web.containerSecurityContext | object | `{}` |  |
| sentry.web.customResponseHeaders | list | `[]` |  |
| sentry.web.enabled | bool | `true` |  |
| sentry.web.env | list | `[]` |  |
| sentry.web.existingSecretEnv | string | `""` |  |
| sentry.web.livenessProbe.failureThreshold | int | `5` |  |
| sentry.web.livenessProbe.initialDelaySeconds | int | `10` |  |
| sentry.web.livenessProbe.periodSeconds | int | `10` |  |
| sentry.web.livenessProbe.successThreshold | int | `1` |  |
| sentry.web.livenessProbe.timeoutSeconds | int | `2` |  |
| sentry.web.nodeSelector | object | `{}` |  |
| sentry.web.readinessProbe.failureThreshold | int | `2` |  |
| sentry.web.readinessProbe.initialDelaySeconds | int | `10` |  |
| sentry.web.readinessProbe.periodSeconds | int | `3` |  |
| sentry.web.readinessProbe.successThreshold | int | `1` |  |
| sentry.web.readinessProbe.timeoutSeconds | int | `2` |  |
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
| snuba.api.livenessProbe.failureThreshold | int | `5` |  |
| snuba.api.livenessProbe.initialDelaySeconds | int | `10` |  |
| snuba.api.livenessProbe.periodSeconds | int | `10` |  |
| snuba.api.livenessProbe.successThreshold | int | `1` |  |
| snuba.api.livenessProbe.timeoutSeconds | int | `2` |  |
| snuba.api.nodeSelector | object | `{}` |  |
| snuba.api.readinessProbe.failureThreshold | int | `2` |  |
| snuba.api.readinessProbe.initialDelaySeconds | int | `10` |  |
| snuba.api.readinessProbe.periodSeconds | int | `3` |  |
| snuba.api.readinessProbe.successThreshold | int | `1` |  |
| snuba.api.readinessProbe.timeoutSeconds | int | `2` |  |
| snuba.api.replicas | int | `1` |  |
| snuba.api.resources | object | `{}` |  |
| snuba.api.securityContext | object | `{}` |  |
| snuba.api.service.annotations | object | `{}` |  |
| snuba.api.sidecars | list | `[]` |  |
| snuba.api.topologySpreadConstraints | list | `[]` |  |
| snuba.api.volumes | list | `[]` |  |
| snuba.clickhouse.maxConnections | int | `100` |  |
| snuba.consumer.affinity | object | `{}` |  |
| snuba.consumer.containerSecurityContext | object | `{}` |  |
| snuba.consumer.enabled | bool | `true` |  |
| snuba.consumer.env | list | `[]` |  |
| snuba.consumer.livenessProbe.enabled | bool | `true` |  |
| snuba.consumer.livenessProbe.initialDelaySeconds | int | `5` |  |
| snuba.consumer.livenessProbe.periodSeconds | int | `320` |  |
| snuba.consumer.maxBatchTimeMs | int | `750` |  |
| snuba.consumer.maxPollIntervalMs | int | `300000` | Kafka `--max-poll-interval-ms` (self-hosted `SENTRY_KAFKA_MAX_POLL_INTERVAL_MS`). Set `null` to omit the flag. |
| snuba.consumer.nodeSelector | object | `{}` |  |
| snuba.consumer.replicas | int | `1` |  |
| snuba.consumer.resources | object | `{}` |  |
| snuba.consumer.securityContext | object | `{}` |  |
| snuba.consumer.topologySpreadConstraints | list | `[]` |  |
| snuba.dbInitJob.env | list | `[]` |  |
| snuba.eapItemsConsumer.maxPollIntervalMs | int | `300000` | Kafka `--max-poll-interval-ms` (self-hosted `SENTRY_KAFKA_MAX_POLL_INTERVAL_MS`). Set `null` to omit the flag. |
| snuba.genericMetricsCountersConsumer.affinity | object | `{}` |  |
| snuba.genericMetricsCountersConsumer.containerSecurityContext | object | `{}` |  |
| snuba.genericMetricsCountersConsumer.enabled | bool | `true` |  |
| snuba.genericMetricsCountersConsumer.env | list | `[]` |  |
| snuba.genericMetricsCountersConsumer.livenessProbe.enabled | bool | `true` |  |
| snuba.genericMetricsCountersConsumer.livenessProbe.initialDelaySeconds | int | `5` |  |
| snuba.genericMetricsCountersConsumer.livenessProbe.periodSeconds | int | `320` |  |
| snuba.genericMetricsCountersConsumer.maxBatchTimeMs | int | `750` |  |
| snuba.genericMetricsCountersConsumer.maxPollIntervalMs | int | `300000` | Kafka `--max-poll-interval-ms` (self-hosted `SENTRY_KAFKA_MAX_POLL_INTERVAL_MS`). Set `null` to omit the flag. |
| snuba.genericMetricsCountersConsumer.nodeSelector | object | `{}` |  |
| snuba.genericMetricsCountersConsumer.replicas | int | `1` |  |
| snuba.genericMetricsCountersConsumer.resources | object | `{}` |  |
| snuba.genericMetricsCountersConsumer.securityContext | object | `{}` |  |
| snuba.genericMetricsCountersConsumer.topologySpreadConstraints | list | `[]` |  |
| snuba.genericMetricsDistributionConsumer.affinity | object | `{}` |  |
| snuba.genericMetricsDistributionConsumer.containerSecurityContext | object | `{}` |  |
| snuba.genericMetricsDistributionConsumer.enabled | bool | `true` |  |
| snuba.genericMetricsDistributionConsumer.env | list | `[]` |  |
| snuba.genericMetricsDistributionConsumer.livenessProbe.enabled | bool | `true` |  |
| snuba.genericMetricsDistributionConsumer.livenessProbe.initialDelaySeconds | int | `5` |  |
| snuba.genericMetricsDistributionConsumer.livenessProbe.periodSeconds | int | `320` |  |
| snuba.genericMetricsDistributionConsumer.maxBatchTimeMs | int | `750` |  |
| snuba.genericMetricsDistributionConsumer.maxPollIntervalMs | int | `300000` | Kafka `--max-poll-interval-ms` (self-hosted `SENTRY_KAFKA_MAX_POLL_INTERVAL_MS`). Set `null` to omit the flag. |
| snuba.genericMetricsDistributionConsumer.nodeSelector | object | `{}` |  |
| snuba.genericMetricsDistributionConsumer.replicas | int | `1` |  |
| snuba.genericMetricsDistributionConsumer.resources | object | `{}` |  |
| snuba.genericMetricsDistributionConsumer.securityContext | object | `{}` |  |
| snuba.genericMetricsDistributionConsumer.topologySpreadConstraints | list | `[]` |  |
| snuba.genericMetricsGaugesConsumer.maxPollIntervalMs | int | `300000` | Kafka `--max-poll-interval-ms` (self-hosted `SENTRY_KAFKA_MAX_POLL_INTERVAL_MS`). Set `null` to omit the flag. |
| snuba.genericMetricsSetsConsumer.affinity | object | `{}` |  |
| snuba.genericMetricsSetsConsumer.containerSecurityContext | object | `{}` |  |
| snuba.genericMetricsSetsConsumer.enabled | bool | `true` |  |
| snuba.genericMetricsSetsConsumer.env | list | `[]` |  |
| snuba.genericMetricsSetsConsumer.livenessProbe.enabled | bool | `true` |  |
| snuba.genericMetricsSetsConsumer.livenessProbe.initialDelaySeconds | int | `5` |  |
| snuba.genericMetricsSetsConsumer.livenessProbe.periodSeconds | int | `320` |  |
| snuba.genericMetricsSetsConsumer.maxBatchTimeMs | int | `750` |  |
| snuba.genericMetricsSetsConsumer.maxPollIntervalMs | int | `300000` | Kafka `--max-poll-interval-ms` (self-hosted `SENTRY_KAFKA_MAX_POLL_INTERVAL_MS`). Set `null` to omit the flag. |
| snuba.genericMetricsSetsConsumer.nodeSelector | object | `{}` |  |
| snuba.genericMetricsSetsConsumer.replicas | int | `1` |  |
| snuba.genericMetricsSetsConsumer.resources | object | `{}` |  |
| snuba.genericMetricsSetsConsumer.securityContext | object | `{}` |  |
| snuba.genericMetricsSetsConsumer.topologySpreadConstraints | list | `[]` |  |
| snuba.groupAttributesConsumer.affinity | object | `{}` |  |
| snuba.groupAttributesConsumer.containerSecurityContext | object | `{}` |  |
| snuba.groupAttributesConsumer.enabled | bool | `true` |  |
| snuba.groupAttributesConsumer.env | list | `[]` |  |
| snuba.groupAttributesConsumer.livenessProbe.enabled | bool | `true` |  |
| snuba.groupAttributesConsumer.livenessProbe.initialDelaySeconds | int | `5` |  |
| snuba.groupAttributesConsumer.livenessProbe.periodSeconds | int | `320` |  |
| snuba.groupAttributesConsumer.maxBatchTimeMs | int | `750` |  |
| snuba.groupAttributesConsumer.maxPollIntervalMs | int | `300000` | Kafka `--max-poll-interval-ms` (self-hosted `SENTRY_KAFKA_MAX_POLL_INTERVAL_MS`). Set `null` to omit the flag. |
| snuba.groupAttributesConsumer.nodeSelector | object | `{}` |  |
| snuba.groupAttributesConsumer.replicas | int | `1` |  |
| snuba.groupAttributesConsumer.resources | object | `{}` |  |
| snuba.groupAttributesConsumer.securityContext | object | `{}` |  |
| snuba.groupAttributesConsumer.topologySpreadConstraints | list | `[]` |  |
| snuba.issueOccurrenceConsumer.affinity | object | `{}` |  |
| snuba.issueOccurrenceConsumer.containerSecurityContext | object | `{}` |  |
| snuba.issueOccurrenceConsumer.enabled | bool | `true` |  |
| snuba.issueOccurrenceConsumer.env | list | `[]` |  |
| snuba.issueOccurrenceConsumer.livenessProbe.enabled | bool | `true` |  |
| snuba.issueOccurrenceConsumer.livenessProbe.initialDelaySeconds | int | `5` |  |
| snuba.issueOccurrenceConsumer.livenessProbe.periodSeconds | int | `320` |  |
| snuba.issueOccurrenceConsumer.maxBatchTimeMs | int | `750` |  |
| snuba.issueOccurrenceConsumer.maxPollIntervalMs | int | `300000` | Kafka `--max-poll-interval-ms` (self-hosted `SENTRY_KAFKA_MAX_POLL_INTERVAL_MS`). Set `null` to omit the flag. |
| snuba.issueOccurrenceConsumer.nodeSelector | object | `{}` |  |
| snuba.issueOccurrenceConsumer.replicas | int | `1` |  |
| snuba.issueOccurrenceConsumer.resources | object | `{}` |  |
| snuba.issueOccurrenceConsumer.securityContext | object | `{}` |  |
| snuba.issueOccurrenceConsumer.topologySpreadConstraints | list | `[]` |  |
| snuba.metricsConsumer.affinity | object | `{}` |  |
| snuba.metricsConsumer.containerSecurityContext | object | `{}` |  |
| snuba.metricsConsumer.enabled | bool | `true` |  |
| snuba.metricsConsumer.env | list | `[]` |  |
| snuba.metricsConsumer.livenessProbe.enabled | bool | `true` |  |
| snuba.metricsConsumer.livenessProbe.initialDelaySeconds | int | `5` |  |
| snuba.metricsConsumer.livenessProbe.periodSeconds | int | `320` |  |
| snuba.metricsConsumer.maxBatchTimeMs | int | `750` |  |
| snuba.metricsConsumer.maxPollIntervalMs | int | `300000` | Kafka `--max-poll-interval-ms` (self-hosted `SENTRY_KAFKA_MAX_POLL_INTERVAL_MS`). Set `null` to omit the flag. |
| snuba.metricsConsumer.nodeSelector | object | `{}` |  |
| snuba.metricsConsumer.replicas | int | `1` |  |
| snuba.metricsConsumer.resources | object | `{}` |  |
| snuba.metricsConsumer.securityContext | object | `{}` |  |
| snuba.metricsConsumer.topologySpreadConstraints | list | `[]` |  |
| snuba.migrateJob.env | list | `[]` |  |
| snuba.outcomesAcceptedConsumer.affinity | object | `{}` |  |
| snuba.outcomesAcceptedConsumer.containerSecurityContext | object | `{}` |  |
| snuba.outcomesAcceptedConsumer.enabled | bool | `true` |  |
| snuba.outcomesAcceptedConsumer.env | list | `[]` |  |
| snuba.outcomesAcceptedConsumer.maxBatchTimeMs | int | `750` |  |
| snuba.outcomesAcceptedConsumer.maxPollIntervalMs | int | `300000` | Kafka `--max-poll-interval-ms` (self-hosted `SENTRY_KAFKA_MAX_POLL_INTERVAL_MS`). Set `null` to omit the flag. |
| snuba.outcomesAcceptedConsumer.nodeSelector | object | `{}` |  |
| snuba.outcomesAcceptedConsumer.replicas | int | `1` |  |
| snuba.outcomesAcceptedConsumer.resources | object | `{}` |  |
| snuba.outcomesAcceptedConsumer.securityContext | object | `{}` |  |
| snuba.outcomesAcceptedConsumer.topologySpreadConstraints | list | `[]` |  |
| snuba.outcomesBillingConsumer.affinity | object | `{}` |  |
| snuba.outcomesBillingConsumer.containerSecurityContext | object | `{}` |  |
| snuba.outcomesBillingConsumer.enabled | bool | `true` |  |
| snuba.outcomesBillingConsumer.env | list | `[]` |  |
| snuba.outcomesBillingConsumer.livenessProbe.enabled | bool | `true` |  |
| snuba.outcomesBillingConsumer.livenessProbe.initialDelaySeconds | int | `5` |  |
| snuba.outcomesBillingConsumer.livenessProbe.periodSeconds | int | `320` |  |
| snuba.outcomesBillingConsumer.maxBatchSize | string | `"3"` |  |
| snuba.outcomesBillingConsumer.maxBatchTimeMs | int | `750` |  |
| snuba.outcomesBillingConsumer.maxPollIntervalMs | int | `300000` | Kafka `--max-poll-interval-ms` (self-hosted `SENTRY_KAFKA_MAX_POLL_INTERVAL_MS`). Set `null` to omit the flag. |
| snuba.outcomesBillingConsumer.nodeSelector | object | `{}` |  |
| snuba.outcomesBillingConsumer.replicas | int | `1` |  |
| snuba.outcomesBillingConsumer.resources | object | `{}` |  |
| snuba.outcomesBillingConsumer.securityContext | object | `{}` |  |
| snuba.outcomesBillingConsumer.topologySpreadConstraints | list | `[]` |  |
| snuba.outcomesConsumer.affinity | object | `{}` |  |
| snuba.outcomesConsumer.containerSecurityContext | object | `{}` |  |
| snuba.outcomesConsumer.enabled | bool | `true` |  |
| snuba.outcomesConsumer.env | list | `[]` |  |
| snuba.outcomesConsumer.livenessProbe.enabled | bool | `true` |  |
| snuba.outcomesConsumer.livenessProbe.initialDelaySeconds | int | `5` |  |
| snuba.outcomesConsumer.livenessProbe.periodSeconds | int | `320` |  |
| snuba.outcomesConsumer.maxBatchSize | string | `"3"` |  |
| snuba.outcomesConsumer.maxPollIntervalMs | int | `300000` | Kafka `--max-poll-interval-ms` (self-hosted `SENTRY_KAFKA_MAX_POLL_INTERVAL_MS`). Set `null` to omit the flag. |
| snuba.outcomesConsumer.nodeSelector | object | `{}` |  |
| snuba.outcomesConsumer.replicas | int | `1` |  |
| snuba.outcomesConsumer.resources | object | `{}` |  |
| snuba.outcomesConsumer.securityContext | object | `{}` |  |
| snuba.outcomesConsumer.topologySpreadConstraints | list | `[]` |  |
| snuba.profilingChunksConsumer.maxPollIntervalMs | int | `300000` | Kafka `--max-poll-interval-ms` (self-hosted `SENTRY_KAFKA_MAX_POLL_INTERVAL_MS`). Set `null` to omit the flag. |
| snuba.profilingFunctionsConsumer.affinity | object | `{}` |  |
| snuba.profilingFunctionsConsumer.containerSecurityContext | object | `{}` |  |
| snuba.profilingFunctionsConsumer.env | list | `[]` |  |
| snuba.profilingFunctionsConsumer.livenessProbe.enabled | bool | `true` |  |
| snuba.profilingFunctionsConsumer.livenessProbe.initialDelaySeconds | int | `5` |  |
| snuba.profilingFunctionsConsumer.livenessProbe.periodSeconds | int | `320` |  |
| snuba.profilingFunctionsConsumer.maxBatchTimeMs | int | `750` |  |
| snuba.profilingFunctionsConsumer.maxPollIntervalMs | int | `300000` | Kafka `--max-poll-interval-ms` (self-hosted `SENTRY_KAFKA_MAX_POLL_INTERVAL_MS`). Set `null` to omit the flag. |
| snuba.profilingFunctionsConsumer.nodeSelector | object | `{}` |  |
| snuba.profilingFunctionsConsumer.replicas | int | `1` |  |
| snuba.profilingFunctionsConsumer.resources | object | `{}` |  |
| snuba.profilingFunctionsConsumer.securityContext | object | `{}` |  |
| snuba.profilingFunctionsConsumer.sidecars | list | `[]` |  |
| snuba.profilingFunctionsConsumer.topologySpreadConstraints | list | `[]` |  |
| snuba.profilingProfilesConsumer.affinity | object | `{}` |  |
| snuba.profilingProfilesConsumer.containerSecurityContext | object | `{}` |  |
| snuba.profilingProfilesConsumer.env | list | `[]` |  |
| snuba.profilingProfilesConsumer.livenessProbe.enabled | bool | `true` |  |
| snuba.profilingProfilesConsumer.livenessProbe.initialDelaySeconds | int | `5` |  |
| snuba.profilingProfilesConsumer.livenessProbe.periodSeconds | int | `320` |  |
| snuba.profilingProfilesConsumer.maxBatchTimeMs | int | `750` |  |
| snuba.profilingProfilesConsumer.maxPollIntervalMs | int | `300000` | Kafka `--max-poll-interval-ms` (self-hosted `SENTRY_KAFKA_MAX_POLL_INTERVAL_MS`). Set `null` to omit the flag. |
| snuba.profilingProfilesConsumer.nodeSelector | object | `{}` |  |
| snuba.profilingProfilesConsumer.replicas | int | `1` |  |
| snuba.profilingProfilesConsumer.resources | object | `{}` |  |
| snuba.profilingProfilesConsumer.securityContext | object | `{}` |  |
| snuba.profilingProfilesConsumer.sidecars | list | `[]` |  |
| snuba.profilingProfilesConsumer.topologySpreadConstraints | list | `[]` |  |
| snuba.replacer.affinity | object | `{}` |  |
| snuba.replacer.containerSecurityContext | object | `{}` |  |
| snuba.replacer.enabled | bool | `true` |  |
| snuba.replacer.env | list | `[]` |  |
| snuba.replacer.nodeSelector | object | `{}` |  |
| snuba.replacer.replicas | int | `1` |  |
| snuba.replacer.resources | object | `{}` |  |
| snuba.replacer.securityContext | object | `{}` |  |
| snuba.replacer.topologySpreadConstraints | list | `[]` |  |
| snuba.replaysConsumer.affinity | object | `{}` |  |
| snuba.replaysConsumer.containerSecurityContext | object | `{}` |  |
| snuba.replaysConsumer.enabled | bool | `true` |  |
| snuba.replaysConsumer.env | list | `[]` |  |
| snuba.replaysConsumer.livenessProbe.enabled | bool | `true` |  |
| snuba.replaysConsumer.livenessProbe.initialDelaySeconds | int | `5` |  |
| snuba.replaysConsumer.livenessProbe.periodSeconds | int | `320` |  |
| snuba.replaysConsumer.maxBatchTimeMs | int | `750` |  |
| snuba.replaysConsumer.maxPollIntervalMs | int | `300000` | Kafka `--max-poll-interval-ms` (self-hosted `SENTRY_KAFKA_MAX_POLL_INTERVAL_MS`). Set `null` to omit the flag. |
| snuba.replaysConsumer.nodeSelector | object | `{}` |  |
| snuba.replaysConsumer.replicas | int | `1` |  |
| snuba.replaysConsumer.resources | object | `{}` |  |
| snuba.replaysConsumer.securityContext | object | `{}` |  |
| snuba.replaysConsumer.topologySpreadConstraints | list | `[]` |  |
| snuba.rustConsumer | bool | `false` |  |
| snuba.subscriptionConsumerEvents.affinity | object | `{}` |  |
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
| snuba.subscriptionConsumerEvents.strategyType | string | `nil` | Recreate if replicas=1, else RollingUpdate |
| snuba.subscriptionConsumerEvents.topologySpreadConstraints | list | `[]` |  |
| snuba.subscriptionConsumerMetrics.affinity | object | `{}` |  |
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
| snuba.subscriptionConsumerMetrics.strategyType | string | `nil` | Recreate if replicas=1, else RollingUpdate |
| snuba.subscriptionConsumerMetrics.topologySpreadConstraints | list | `[]` |  |
| snuba.subscriptionConsumerTransactions.affinity | object | `{}` |  |
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
| snuba.subscriptionConsumerTransactions.strategyType | string | `nil` | Recreate if replicas=1, else RollingUpdate |
| snuba.subscriptionConsumerTransactions.topologySpreadConstraints | list | `[]` |  |
| snuba.transactionsConsumer.affinity | object | `{}` |  |
| snuba.transactionsConsumer.containerSecurityContext | object | `{}` |  |
| snuba.transactionsConsumer.enabled | bool | `true` |  |
| snuba.transactionsConsumer.env | list | `[]` |  |
| snuba.transactionsConsumer.livenessProbe.enabled | bool | `true` |  |
| snuba.transactionsConsumer.livenessProbe.initialDelaySeconds | int | `5` |  |
| snuba.transactionsConsumer.livenessProbe.periodSeconds | int | `320` |  |
| snuba.transactionsConsumer.maxBatchTimeMs | int | `750` |  |
| snuba.transactionsConsumer.maxPollIntervalMs | int | `300000` | Kafka `--max-poll-interval-ms` (self-hosted `SENTRY_KAFKA_MAX_POLL_INTERVAL_MS`). Set `null` to omit the flag. |
| snuba.transactionsConsumer.nodeSelector | object | `{}` |  |
| snuba.transactionsConsumer.replicas | int | `1` |  |
| snuba.transactionsConsumer.resources | object | `{}` |  |
| snuba.transactionsConsumer.securityContext | object | `{}` |  |
| snuba.transactionsConsumer.topologySpreadConstraints | list | `[]` |  |
| symbolicator.api.affinity | object | `{}` |  |
| symbolicator.api.autoscaling.enabled | bool | `false` |  |
| symbolicator.api.autoscaling.maxReplicas | int | `5` |  |
| symbolicator.api.autoscaling.minReplicas | int | `2` |  |
| symbolicator.api.autoscaling.targetCPUUtilizationPercentage | int | `50` |  |
| symbolicator.api.config | string | `"# See: https://getsentry.github.io/symbolicator/#configuration\ncache_dir: \"/data\"\nbind: \"0.0.0.0:3021\"\nlogging:\n  level: \"warn\"\nmetrics:\n  statsd: null\n  prefix: \"symbolicator\"\nsentry_dsn: null\nconnect_to_reserved_ips: true\n# caches:\n#   downloaded:\n#     max_unused_for: 1w\n#     retry_misses_after: 5m\n#     retry_malformed_after: 5m\n#   derived:\n#     max_unused_for: 1w\n#     retry_misses_after: 5m\n#     retry_malformed_after: 5m\n#   diagnostics:\n#     retention: 1w"` |  |
| symbolicator.api.containerSecurityContext | object | `{}` |  |
| symbolicator.api.env | list | `[]` |  |
| symbolicator.api.livenessProbe.failureThreshold | int | `5` |  |
| symbolicator.api.livenessProbe.initialDelaySeconds | int | `10` |  |
| symbolicator.api.livenessProbe.periodSeconds | int | `10` |  |
| symbolicator.api.livenessProbe.successThreshold | int | `1` |  |
| symbolicator.api.livenessProbe.timeoutSeconds | int | `2` |  |
| symbolicator.api.nodeSelector | object | `{}` |  |
| symbolicator.api.persistence.accessModes[0] | string | `"ReadWriteOnce"` |  |
| symbolicator.api.persistence.enabled | bool | `true` |  |
| symbolicator.api.persistence.size | string | `"10Gi"` |  |
| symbolicator.api.readinessProbe.failureThreshold | int | `2` |  |
| symbolicator.api.readinessProbe.initialDelaySeconds | int | `10` |  |
| symbolicator.api.readinessProbe.periodSeconds | int | `3` |  |
| symbolicator.api.readinessProbe.successThreshold | int | `1` |  |
| symbolicator.api.readinessProbe.timeoutSeconds | int | `2` |  |
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
| user.password | string | `""` | Plaintext admin password. Required if `user.create` is true and `user.existingSecret` is not set. Using `user.existingSecret` is strongly recommended for production. |
| vroom.affinity | object | `{}` |  |
| vroom.autoscaling.enabled | bool | `false` |  |
| vroom.autoscaling.maxReplicas | int | `5` |  |
| vroom.autoscaling.minReplicas | int | `2` |  |
| vroom.autoscaling.targetCPUUtilizationPercentage | int | `50` |  |
| vroom.containerSecurityContext | object | `{}` |  |
| vroom.env | list | `[]` |  |
| vroom.livenessProbe.failureThreshold | int | `5` |  |
| vroom.livenessProbe.initialDelaySeconds | int | `10` |  |
| vroom.livenessProbe.periodSeconds | int | `10` |  |
| vroom.livenessProbe.successThreshold | int | `1` |  |
| vroom.livenessProbe.timeoutSeconds | int | `2` |  |
| vroom.nodeSelector | object | `{}` |  |
| vroom.readinessProbe.failureThreshold | int | `2` |  |
| vroom.readinessProbe.initialDelaySeconds | int | `10` |  |
| vroom.readinessProbe.periodSeconds | int | `3` |  |
| vroom.readinessProbe.successThreshold | int | `1` |  |
| vroom.readinessProbe.timeoutSeconds | int | `2` |  |
| vroom.replicas | int | `1` |  |
| vroom.resources | object | `{}` |  |
| vroom.securityContext | object | `{}` |  |
| vroom.service.annotations | object | `{}` |  |
| vroom.sidecars | list | `[]` |  |
| vroom.volumeMounts | list | `[]` |  |
| vroom.volumes | list | `[]` |  |
| vroom.persistence.enabled | bool | `true` | Enable persistence for vroom (uses PVC if true, emptyDir if false) |
| vroom.persistence.lookupVolumeName | bool | `true` | Lookup and use existing volume name |
| vroom.persistence.accessModes[0] | string | `"ReadWriteOnce"` | Access mode for vroom PVC. Use ReadWriteMany if sharing with ingest-profiles (filestore.profiles.filesystem.persistence.shareWithVroom) |
| vroom.persistence.size | string | `"10Gi"` | Size of vroom PVC |
| vroom.persistence.storageClassName | string | `nil` | Storage class for vroom PVC |

## Routing

This chart supports **four mutually exclusive** exposure modes. **Enable exactly one**.
All routing options are **disabled by default**, so you must choose and enable one:

- Gateway API HTTPRoute (`route.main.enabled`)
- Traefik IngressRoute (`traefikIngressRoute.enabled`)
- Kubernetes Ingress (`ingress.enabled`)
- In-cluster nginx reverse proxy Service (`nginx.enabled`)

**Important:** Do **not** enable more than one of `ingress.enabled`, `route.main.enabled`, `traefikIngressRoute.enabled`, or `nginx.enabled`.
In particular, running Kubernetes Ingress / Gateway API / Traefik **in front of** the in-cluster nginx (proxy chaining) is **discouraged**: it adds an extra hop, increases latency, and can reduce throughput.

Sentry does not support subpath deployments; all routes assume the application is served at `/`.

### Gateway API (HTTPRoute)

The chart also supports [Kubernetes Gateway API](https://gateway-api.sigs.k8s.io/) HTTPRoute as an alternative to traditional Ingress.

Ingestion endpoints (`/api/*`) are routed to Relay, while UI and other API endpoints go to the web service (`/api/store` goes to Relay).

```yaml
route:
  main:
    enabled: true
    hostnames:
      - sentry.example.com
    parentRefs:
      - name: my-gateway
        namespace: default
```

With HTTP to HTTPS redirect:

```yaml
route:
  main:
    enabled: true
    hostnames:
      - sentry.example.com
    parentRefs:
      - name: my-gateway
        sectionName: https
  httpRedirect:
    enabled: true
    parentRefs:
      - name: my-gateway
        sectionName: http
```

### Traefik IngressRoute

If you run Traefik, you can enable the bundled `IngressRoute` resources instead of standard Ingress.

The Traefik routes use `traefikIngressRoute.hostname` (defaults to `ingress.hostname`).

```yaml
traefikIngressRoute:
  enabled: true
  hostname: sentry.example.com
  tls:
    secretName: sentry-tls

```

### Kubernetes Ingress (nginx, traefik, AWS ALB, GCE)

Routing rules are defined by `ingress.pathRules`, keyed by controller style. The controller style is selected by `ingress.ingressClassName`; for custom class names, set `ingress.regexPathStyle` to one of `nginx`, `traefik`, `alb`, or `gce`.

Defaults target nginx-ingress. If you override `ingress.annotations`, keep `nginx.ingress.kubernetes.io/use-regex: "true"` for nginx.
If you need per-path annotations or extra routing rules, create additional Ingress objects via `extraManifests`.

For AWS ALB HTTPS redirect, set these annotations in `ingress.annotations`:

```yaml
ingress:
  annotations:
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80}, {"HTTPS":443}]'
    alb.ingress.kubernetes.io/ssl-redirect: '443'
```

If you are using `additionalHostNames`, the `nginx.ingress.kubernetes.io/upstream-vhost` annotation might also come in handy.
It sets the `Host` header to the value you provide to avoid CSRF issues.

#### Letsencrypt on NGINX Ingress Controller

```yaml
ingress:
  enabled: true
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
  hostname: fqdn
  ingressClassName: "nginx"
  tls:
    - secretName: sentry-tls
      hosts:
        - fqdn
```


### NGINX service

If you prefer a single in-cluster Service as the HTTP entrypoint (for example to attach a `LoadBalancer` directly, or to use nginx `location` snippets), you can enable the bundled nginx reverse proxy based on the CloudPirates `nginx` chart dependency.

```yaml

nginx:
  enabled: true
  # Optional: add extra nginx locations/snippets
  # extraLocationSnippet: |
  #   location /admin {
  #     allow 1.2.3.4;
  #     deny all;
  #     proxy_pass http://sentry;
  #   }
```

Notes:

- When `nginx.enabled=true`, the chart creates an nginx config ConfigMap (see `templates/routing/nginx-config.yaml`) that proxies to `sentry-web` and, when enabled, to `relay` for ingestion endpoints.
- Expose the `*-nginx` Service by configuring the nginx chart values (for example `nginx.service.type=LoadBalancer`).
- Using an additional router in front of this in-cluster nginx is discouraged (see warning above).


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

To get javascript source map processing working, the Django cache (memcached) is enabled by default, which is also used by 60+ Sentry components for caching.

For details on the background see this blog post: https://engblog.yext.com/post/sentry-js-source-maps

## External storage (filestore, replays, profiles)

Sentry can offload blobs to filesystem or bucket storage. See the Sentry docs for details and backend-specific caveats:
https://develop.sentry.dev/self-hosted/production-enhancements/external-storage/

### Filestore (attachments, sourcemaps, and default replays)

Set `filestore.backend` to one of `filesystem`, `s3`, or `gcs`:

```yaml
filestore:
  backend: gcs
  gcs:
    bucketName: sentry-filestore
    secretName: sentry-gcs
    credentialsFile: credentials.json
```

### Replays storage (optional separate backend)

By default, replays use the main filestore. To store replays separately, set `replay.storage.backend` to `filesystem`, `s3`, or `gcs`.

Filesystem example (keep the path inside a mounted volume or add your own volume mounts):

```yaml
replay:
  storage:
    backend: filesystem
    filesystem:
      path: /var/lib/sentry/files/replays
```

Filesystem with a separate PVC (different from filestore):

```yaml
replay:
  storage:
    backend: filesystem
    filesystem:
      path: /var/lib/sentry/replays
      persistence:
        enabled: true
        size: 20Gi
```

S3 example:

```yaml
replay:
  storage:
    backend: s3
    s3:
      bucketName: sentry-replays
      endpointUrl: https://s3.example.com
      region_name: auto
      signature_version: s3v4
      default_acl: private
      bucket_acl: private
```

GCS example:

```yaml
replay:
  storage:
    backend: gcs
    gcs:
      bucketName: sentry-replays
      secretName: sentry-gcs
      credentialsFile: credentials.json
```

When using GCS for both filestore and replays, `replay.storage.gcs.secretName` and
`replay.storage.gcs.credentialsFile` must match `filestore.gcs.*`.

### Profiles storage (vroom)

Profiling uses `filestore.profiles`. Supported backends are `filesystem`, `gcs` and `s3` (object storage is recommended for production).

- Keep `vroom.persistence.bucketString` and `filestore.profiles.*` pointed at the same bucket/prefix.
- For `filesystem` backend, if `filestore.profiles.filesystem.persistence.shareWithVroom=true`, set `vroom.persistence.accessModes` to include `ReadWriteMany`.
- For `gcs` backend, Sentry pods mount a single GCS credentials secret. If `filestore.backend` or `replay.storage.backend` is also set to `gcs`, the corresponding `secretName` and `credentialsFile` must match `filestore.profiles.gcs.*`.
- Configure vroom credentials yourself via `vroom.env`, `vroom.volumeMounts`, and `vroom.volumes`.

S3 example:

```yaml
filestore:
  profiles:
    backend: s3
    s3:
      existingSecret: sentry-profiles-s3
      bucketName: sentry-profiles
vroom:
  persistence:
    bucketString: "s3://sentry-profiles"
  env:
    - name: AWS_ACCESS_KEY_ID
      valueFrom:
        secretKeyRef:
          name: sentry-profiles-s3
          key: s3-access-key-id
    - name: AWS_SECRET_ACCESS_KEY
      valueFrom:
        secretKeyRef:
          name: sentry-profiles-s3
          key: s3-secret-access-key
```

GCS example:

```yaml
filestore:
  profiles:
    backend: gcs
    gcs:
      bucketName: sentry-profiles
      secretName: sentry-storage-creds
      credentialsFile: credentials.json
vroom:
  persistence:
    enabled: false
    bucketString: "gs://sentry-profiles"
  env:
    - name: GOOGLE_APPLICATION_CREDENTIALS
      value: /var/run/secrets/google/credentials.json
  volumeMounts:
    - mountPath: /var/run/secrets/google
      name: sentry-google-cloud-key
  volumes:
    - name: sentry-google-cloud-key
      secret:
        secretName: sentry-storage-creds
```

### Retention and lifecycle policies

- For S3 or GCS, all buckets except the **main filestore** should have a lifecycle policy to delete objects after your retention period (match `sentry.cleanup.days` / `SENTRY_EVENT_RETENTION_DAYS`).
- For the main filestore bucket, you may configure a lifecycle rule to delete objects under `eventattachments/` after retention; other filestore paths should remain indefinitely.

## Nodestore (raw events)

Sentry stores raw event payloads in the nodestore. This chart supports an S3-compatible nodestore backend.
When enabled, the `sentry-nodestore-s3` package is installed automatically via init containers.

Example:

```yaml
nodestore:
  backend: s3
  s3:
    bucketName: sentry-nodestore
    bucketPath: nodestore
    endpointUrl: https://s3.example.com
    regionName: us-east-1
```

You can also supply credentials via an existing secret:

```yaml
nodestore:
  backend: s3
  s3:
    existingSecret: nodestore-s3-credentials
    accessKeyIdRef: s3-access-key-id
    secretAccessKeyRef: s3-secret-access-key
    bucketName: sentry-nodestore
```


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
- [External Services](docs/external-services.md)

