{{- define "sentry.config" -}}
{{- $redisHost := include "sentry.redis.host" . -}}
{{- $redisPort := include "sentry.redis.port" . -}}
{{- $redisPass := include "sentry.redis.password" . -}}
{{- $redisDb     := include "sentry.redis.db" . -}}
{{- $redisProto  := ternary "rediss" "redis" (eq (include "sentry.redis.ssl" .) "true")  -}}
config.yml: |-
  {{- if .Values.system.adminEmail }}
  system.admin-email: {{ .Values.system.adminEmail | quote }}
  {{- end }}
  {{- if .Values.system.url }}
  system.url-prefix: {{ .Values.system.url | quote }}
  {{- end }}

  # This URL will be used to tell Symbolicator where to obtain the Sentry source.
  # See https://getsentry.github.io/symbolicator/api/
  system.internal-url-prefix: 'http://{{ template "sentry.fullname" . }}-web:{{ .Values.service.externalPort }}'
  symbolicator.enabled: {{ .Values.symbolicator.enabled }}
  {{- if .Values.symbolicator.enabled }}
  symbolicator.options:
    url: "http://{{ template "sentry.fullname" . }}-symbolicator:{{ template "symbolicator.port" }}"
  {{- end }}

  ##########
  # Github #
  ##########
  {{- with .Values.github.appId }}
  github-app.id: {{ . }}
  {{- end }}
  {{- with .Values.github.appName }}
  github-app.name: {{ . | quote }}
  {{- end }}
  {{- if not .Values.github.existingSecret }}
    {{- with .Values.github.privateKey }}
  github-app.private-key: {{- . | toYaml | indent 2 }}
    {{- end }}
    {{- with .Values.github.webhookSecret }}
  github-app.webhook-secret: {{ . | quote }}
    {{- end }}
    {{- with .Values.github.clientId }}
  github-app.client-id: {{ . | quote }}
    {{- end }}
    {{- with .Values.github.clientSecret }}
  github-app.client-secret: {{ . | quote }}
    {{- end }}
  {{- end }}

  ##########
  # Google #
  ##########
  {{- if and (.Values.google.clientId) (.Values.google.clientSecret) (not .Values.google.existingSecret) }}
  auth-google.client-id: {{ .Values.google.clientId | quote }}
  auth-google.client-secret: {{ .Values.google.clientSecret | quote }}
  {{- end }}

  #########
  # Slack #
  #########
  {{- if and (.Values.slack.clientId) (.Values.slack.clientSecret) (.Values.slack.signingSecret) (not .Values.slack.existingSecret) }}
  slack.client-id: {{ .Values.slack.clientId | quote }}
  slack.client-secret: {{ .Values.slack.clientSecret | quote }}
  slack.signing-secret: {{ .Values.slack.signingSecret | quote }}
  {{ end }}

  ###########
  # Discord #
  ###########
  {{- if and (.Values.discord.applicationId) (.Values.discord.publicKey) (.Values.discord.clientSecret) (.Values.discord.botToken) (not .Values.discord.existingSecret) }}
  discord.application-id: {{ .Values.discord.applicationId | quote }}
  discord.public-key: {{ .Values.discord.publicKey | quote }}
  discord.client-secret: {{ .Values.discord.clientSecret | quote }}
  discord.bot-token: {{ .Values.discord.botToken | quote }}
  {{ end }}

  #########
  # Redis #
  #########
  # This is configured in the sentry.conf.py as that has support for environment variables.

  {{- if .Values.config.taskbrokerRoutingYml }}
  {{ .Values.config.taskbrokerRoutingYml | toYaml | nindent 2 }}
  {{- end }}

  {{- if .Values.config.configYml }}
  {{ .Values.config.configYml | toYaml | nindent 2 }}
  {{- end }}
sentry.conf.py: |-
  from sentry.conf.server import *  # NOQA

  BYTE_MULTIPLIER = 1024
  UNITS = ("K", "M", "G")
  def unit_text_to_bytes(text):
      unit = text[-1].upper()
      power = UNITS.index(unit) + 1
      return float(text[:-1])*(BYTE_MULTIPLIER**power)

  CACHES = {
      "default": {
          "BACKEND": "sentry.cache.backends.reconnectingmemcache.ReconnectingMemcache",
          "LOCATION": [
              "{{ template "sentry.fullname" . }}-memcached:11211"
          ],
          "TIMEOUT": 3600,
          "OPTIONS": {"ignore_exc": True, "reconnect_age": 300}
      }
  }

  DATABASES = {
      "default": {
          "ENGINE": "sentry.db.postgres",
          "NAME": os.environ.get("POSTGRES_NAME", ""),
          "USER": os.environ.get("POSTGRES_USER", ""),
          "PASSWORD": os.environ.get("POSTGRES_PASSWORD", ""),
          "HOST": os.environ.get("POSTGRES_HOST", ""),
          "PORT": os.environ.get("POSTGRES_PORT", ""),
          {{- if .Values.postgresql.enabled }}
          "CONN_MAX_AGE": {{ .Values.postgresql.connMaxAge }},
          {{- else }}
          "CONN_MAX_AGE": {{ .Values.externalPostgresql.connMaxAge }},
          {{- end }}
          {{- if .Values.externalPostgresql.sslMode }}
          'OPTIONS': {
              'sslmode': '{{ .Values.externalPostgresql.sslMode }}',
          },
          {{- end }}
      }
  }

  {{- if .Values.geodata.path }}
  GEOIP_PATH_MMDB = {{ .Values.geodata.path | quote }}
  {{- end }}

  # You should not change this setting after your database has been created
  # unless you have altered all schemas first
  SENTRY_USE_BIG_INTS = True

  ###########
  # General #
  ###########

  # Disable sends anonymous usage statistics
  SENTRY_BEACON = False

  secret_key = env('SENTRY_SECRET_KEY')
  if not secret_key:
    raise Exception('Error: SENTRY_SECRET_KEY is undefined')

  SENTRY_OPTIONS['system.secret-key'] = secret_key

  # Set default for SAMPLED_DEFAULT_RATE:
  SAMPLED_DEFAULT_RATE = {{ .Values.global.sampledDefaultRate | default 1.0 }}

  # Instruct Sentry that this install intends to be run by a single organization
  # and thus various UI optimizations should be enabled.
  SENTRY_SINGLE_ORGANIZATION = {{ if .Values.sentry.singleOrganization }}True{{ else }}False{{ end }}

  SENTRY_OPTIONS["system.event-retention-days"] = int(env('SENTRY_EVENT_RETENTION_DAYS') or {{ .Values.sentry.cleanup.days | quote }})

  {{- if has "errors-only" .Values.profiles }}
  SENTRY_SELF_HOSTED_ERRORS_ONLY = True
  {{- end }}

  #########
  # Redis #
  #########

  # Generic Redis configuration used as defaults for various things including:
  # Buffers, Quotas, TSDB
  SENTRY_OPTIONS["redis.clusters"] = {
    "default": {
      "hosts": {
        0: {
          "host": {{ $redisHost | quote }},
          "password": os.environ.get("REDIS_PASSWORD", {{ $redisPass | quote }}),
          "port": {{ $redisPort | quote }},
          {{- if .Values.externalRedis.ssl }}
          "ssl": {{ .Values.externalRedis.ssl | quote }},
          {{- end }}
          "db": {{ $redisDb | quote }}
        }
      }
    }
  }

  # A primary cache is required for things such as processing events
  SENTRY_CACHE = "sentry.cache.redis.RedisCache"

  DEFAULT_KAFKA_OPTIONS = {
      "common": {
          "bootstrap.servers": {{ (include "sentry.kafka.bootstrap_servers_string" .) | quote }},
          "message.max.bytes": {{ include "sentry.kafka.message_max_bytes" . }},
      {{- $sentryKafkaCompressionType := include "sentry.kafka.compression_type" . -}}
      {{- if $sentryKafkaCompressionType }}
          "compression.type": {{ $sentryKafkaCompressionType | quote }},
      {{- end }}
          "socket.timeout.ms": {{ include "sentry.kafka.socket_timeout_ms" . }},
      {{- if and (not .Values.kafka.enabled) .Values.externalKafka.sasl.existingSecret }}
          "sasl.mechanism": os.getenv("KAFKA_SASL_MECHANISM", ""),
          "sasl.username": os.getenv("KAFKA_SASL_USERNAME", ""),
          "sasl.password": os.getenv("KAFKA_SASL_PASSWORD", ""),
      {{- else }}
      {{- $sentryKafkaSaslMechanism := include "sentry.kafka.sasl_mechanism" . -}}
      {{- if not (eq "None" $sentryKafkaSaslMechanism) }}
          "sasl.mechanism": {{ $sentryKafkaSaslMechanism | quote }},
      {{- end }}
      {{- $sentryKafkaSaslUsername := include "sentry.kafka.sasl_username" . -}}
      {{- if not (eq "None" $sentryKafkaSaslUsername) }}
          "sasl.username": {{ $sentryKafkaSaslUsername | quote }},
      {{- end }}
      {{- $sentryKafkaSaslPassword := include "sentry.kafka.sasl_password" . -}}
      {{- if not (eq "None" $sentryKafkaSaslPassword) }}
          "sasl.password": {{ $sentryKafkaSaslPassword | quote }},
      {{- end }}
      {{- end }}
      {{- $sentryKafkaSecurityProtocol := include "sentry.kafka.security_protocol" . -}}
      {{- if not (eq "plaintext" $sentryKafkaSecurityProtocol) }}
          "security.protocol": {{ $sentryKafkaSecurityProtocol | quote }},
      {{- end }}
      }
  }

  SENTRY_EVENTSTREAM = "sentry.eventstream.kafka.KafkaEventStream"
  SENTRY_EVENTSTREAM_OPTIONS = {"producer_configuration": DEFAULT_KAFKA_OPTIONS}

  {{- if ((.Values.kafkaTopicOverrides).prefix) }}
  SENTRY_CHARTS_KAFKA_TOPIC_PREFIX = {{ .Values.kafkaTopicOverrides.prefix | quote }}

  from sentry.conf.types.kafka_definition import Topic
  for topic in Topic:
    KAFKA_TOPIC_OVERRIDES[topic.value] = f"{SENTRY_CHARTS_KAFKA_TOPIC_PREFIX}{topic.value}"
  {{- end }}

  KAFKA_CLUSTERS["default"] = DEFAULT_KAFKA_OPTIONS

  ###############
  # Rate Limits #
  ###############

  # Rate limits apply to notification handlers and are enforced per-project
  # automatically.

  SENTRY_RATELIMITER = "sentry.ratelimits.redis.RedisRateLimiter"

  ##################
  # Update Buffers #
  ##################

  # Buffers (combined with queueing) act as an intermediate layer between the
  # database and the storage API. They will greatly improve efficiency on large
  # numbers of the same events being sent to the API in a short amount of time.
  # (read: if you send any kind of real data to Sentry, you should enable buffers)

  SENTRY_BUFFER = "sentry.buffer.redis.RedisBuffer"

  ##########
  # Quotas #
  ##########

  # Quotas allow you to rate limit individual projects or the Sentry install as
  # a whole.

  SENTRY_QUOTAS = "sentry.quotas.redis.RedisQuota"

  ########
  # TSDB #
  ########

  # The TSDB is used for building charts as well as making things like per-rate
  # alerts possible.

  SENTRY_TSDB = "sentry.tsdb.redissnuba.RedisSnubaTSDB"

  #########
  # SNUBA #
  #########

  SENTRY_SEARCH = "sentry.search.snuba.EventsDatasetSnubaSearchBackend"
  SENTRY_SEARCH_OPTIONS = {}
  SENTRY_TAGSTORE_OPTIONS = {}

  ###########
  # Digests #
  ###########

  # The digest backend powers notification summaries.

  SENTRY_DIGESTS = "sentry.digests.backends.redis.RedisBackend"

  ###################
  # Metrics Backend #
  ###################

  SENTRY_RELEASE_HEALTH = "sentry.release_health.metrics.MetricsReleaseHealthBackend"
  SENTRY_RELEASE_MONITOR = "sentry.release_health.release_monitor.metrics.MetricReleaseMonitorBackend"

  ##############
  # Web Server #
  ##############

  {{- if .Values.ipv6 }}
  SENTRY_WEB_HOST = "[::]"
  {{- else }}
  SENTRY_WEB_HOST = "0.0.0.0"
  {{- end }}


  SENTRY_WEB_PORT = {{ template "sentry.port" }}
  SENTRY_PUBLIC = {{ .Values.system.public | ternary "True" "False" }}
  SENTRY_WEB_OPTIONS = {
  {{- if .Values.ipv6 }}
      "http-socket": "%s:%s" % (SENTRY_WEB_HOST, SENTRY_WEB_PORT),
  {{- else }}
      "http": "%s:%s" % (SENTRY_WEB_HOST, SENTRY_WEB_PORT),
  {{- end }}
      "protocol": "uwsgi",
      # This is needed to prevent https://git.io/fj7Lw
      "uwsgi-socket": None,
      # Keep this between 15s-75s as that's what Relay supports
      "http-keepalive": {{ .Values.config.web.httpKeepalive | int }},
      "http-chunked-input": {{ .Values.config.web.httpChunkedInput | ternary "True" "False" }},
      # the number of web workers
      'workers': {{ .Values.config.web.workers | int }},
      'threads': {{ .Values.config.web.threads | int }},
      # Turn off memory reporting
      "memory-report": {{ .Values.config.web.memoryReport | ternary "True" "False" }},
      # Some stuff so uwsgi will cycle workers sensibly
      'max-requests': {{ .Values.config.web.maxRequests | int }},
      'max-requests-delta': {{ .Values.config.web.maxRequestsDelta | int }},
      'max-worker-lifetime': {{ .Values.config.web.maxWorkerLifetime | int }},
      # Duplicate options from sentry default just so we don't get
      # bit by sentry changing a default value that we depend on.
      'thunder-lock': {{ .Values.config.web.thunderLock | ternary "True" "False" }},
      'log-x-forwarded-for': {{ .Values.config.web.logXForwardedFor | ternary "True" "False" }},
      'buffer-size': {{ .Values.config.web.bufferSize | int }},
      'limit-post': {{ .Values.config.web.limitPost | int }},
      'disable-logging': {{ .Values.config.web.disableLogging | ternary "True" "False" }},
      'reload-on-rss': {{ .Values.config.web.reloadOnRss | int }},
      'ignore-sigpipe': {{ .Values.config.web.ignoreSignpipe | ternary "True" "False" }},
      'ignore-write-errors': {{ .Values.config.web.ignoreWriteErrors | ternary "True" "False" }},
      'disable-write-exception': {{ .Values.config.web.disableWriteException | ternary "True" "False" }},
  }

  ###########
  # SSL/TLS #
  ###########

  # If you're using a reverse SSL proxy, you should enable the X-Forwarded-Proto
  # header and enable the settings below

  # SECURE_PROXY_SSL_HEADER = ('HTTP_X_FORWARDED_PROTO', 'https')
  # SESSION_COOKIE_SECURE = True
  # CSRF_COOKIE_SECURE = True
  # SOCIAL_AUTH_REDIRECT_IS_HTTPS = True

  # End of SSL/TLS settings

  ############
  # Features #
  ############


  SENTRY_FEATURES = {
    "auth:register": {{ .Values.auth.register | ternary "True" "False" }}
  }
  SENTRY_FEATURES["projects:sample-events"] = False
  SENTRY_FEATURES.update(
      {
          feature: True
          for feature in (
              {{- if not .Values.sentry.singleOrganization }}
              "organizations:create",
              {{- end }}
              {{- if .Values.sentry.features.orgSubdomains }}
              "organizations:org-ingest-subdomains",
              {{- end }}
              "organizations:discover",
              "organizations:global-views",
              "organizations:issue-views",
              "organizations:incidents",
              "organizations:integrations-issue-basic",
              "organizations:integrations-issue-sync",
              "organizations:invite-members",
              "organizations:sso-basic",
              "organizations:sso-saml2",
              "organizations:advanced-search",
              "organizations:issue-platform",
              "organizations:monitors",
              "organizations:dashboards-mep",
              "organizations:mep-rollout-flag",
              "organizations:dashboards-rh-widget",
              "organizations:dynamic-sampling",
              "projects:custom-inbound-filters",
              "projects:data-forwarding",
              "projects:discard-groups",
              "projects:plugins",
              "projects:rate-limits",
              "projects:servicehooks",
          )
          {{- if .Values.sentry.features.enableSpan }}
          + (
              # Performance/Tracing/Spans
              "organizations:performance-view",
              "organizations:span-stats",
              "organizations:visibility-explore-view",
              "organizations:visibility-explore-range-high",
              "organizations:transaction-metrics-extraction",
              "organizations:indexed-spans-extraction",
              "organizations:insights-entry-points",
              "organizations:insights-initial-modules",
              "organizations:insights-addon-modules",
              "organizations:insights-modules-use-eap",
              "organizations:starfish-mobile-appstart",
              "organizations:on-demand-metrics-extraction",
              "projects:span-metrics-extraction",
              "projects:span-metrics-extraction-addons",

              # extra trace UI flags from chart
              "organizations:trace-view-load-more",
              "organizations:trace-tabs-ui",
              "organizations:trace-view-linked-traces",
          )
          {{- end }}
          {{- if .Values.sentry.features.enableSessionReplay }}
          + (
              # Session Replay
              "organizations:session-replay",
              "organizations:session-replay-ui",
              "organizations:session-replay-issue-emails",
              "organizations:session-replay-recording-scrubbing",
              "organizations:session-replay-slack-new-issue",
          )
          {{- end }}
          {{- if .Values.sentry.features.enableFeedback }}
          + (
              # User Feedback
              "organizations:user-feedback-ui",
          )
          {{- end }}
          {{- if .Values.sentry.features.enableProfiling }}
          + (
              # Profiling
              "organizations:profiling",
              "organizations:profiling-view",

              # Continuous Profiling
              "organizations:continuous-profiling",
              "organizations:continuous-profiling-stats",
          )
          {{- end }}
          {{- if .Values.sentry.features.enableUptime }}
          + (
              # Uptime Monitoring
              "organizations:uptime",
              "organizations:uptime-create-issues",
          )
          {{- end }}
          + (
              # Logs (OurLogs)
              "organizations:ourlogs-enabled",
              "organizations:ourlogs-ingestion",
              "organizations:ourlogs-stats",
              "organizations:ourlogs-replay-ui",

              # Metrics (Trace Metrics)
              "organizations:tracemetrics-enabled",
              "organizations:tracemetrics-alerts",
              "organizations:tracemetrics-ingestion",
              "organizations:tracemetrics-equations-in-alerts",
              "organizations:tracemetrics-equations-in-explore",
              "organizations:tracemetrics-multi-metric-selection-in-dashboards",
              "organizations:tracemetrics-units-ui",
              "organizations:tracemetrics-stats-bytes-ui",
              "organizations:tracemetrics-pii-scrubbing-ui",

              # Chart-only / misc
              "organizations:related-events",
              "organizations:reprocessing-v2",
              "organizations:set-grouping-config",
              "organizations:onboarding",
              "projects:similarity-indexing",
              "projects:similarity-view",
          )
          {{- if .Values.sentry.customFeatures }}
          + (
              # Custom features from values
              {{- range $CustomFeature := .Values.sentry.customFeatures }}
              "{{ $CustomFeature }}",
              {{- end }}
          )
          {{- end }}
      }
  )

  #######################
  # Email Configuration #
  #######################
  SENTRY_OPTIONS['mail.backend'] = os.getenv("SENTRY_EMAIL_BACKEND", {{ .Values.mail.backend | quote }})
  SENTRY_OPTIONS['mail.use-tls'] = os.getenv("SENTRY_EMAIL_USE_TLS", {{ .Values.mail.useTls | quote }}).lower() in ("true", "1", "yes")
  SENTRY_OPTIONS['mail.use-ssl'] = os.getenv("SENTRY_EMAIL_USE_SSL", {{ .Values.mail.useSsl | quote }}).lower() in ("true", "1", "yes")
  SENTRY_OPTIONS['mail.username'] = os.getenv("SENTRY_EMAIL_USERNAME", {{ .Values.mail.username | quote }})
  SENTRY_OPTIONS['mail.password'] = os.getenv("SENTRY_EMAIL_PASSWORD", "")
  SENTRY_OPTIONS['mail.port'] = int(os.getenv("SENTRY_EMAIL_PORT", {{ .Values.mail.port | quote }}))
  SENTRY_OPTIONS['mail.host'] = os.getenv("SENTRY_EMAIL_HOST", {{ .Values.mail.host | quote }})
  SENTRY_OPTIONS['mail.from'] = os.getenv("SENTRY_EMAIL_FROM", {{ .Values.mail.from | quote }})

  ################
  # File storage #
  ################
  SENTRY_OPTIONS['filestore.backend'] = {{ .Values.filestore.backend | quote }}

  {{- if eq .Values.filestore.backend "filesystem" }}
  SENTRY_OPTIONS['filestore.options'] = {
      'location': {{ .Values.filestore.filesystem.path | quote }},
  }
  {{- end }}

  {{- if eq .Values.filestore.backend "gcs" }}
  SENTRY_OPTIONS['filestore.options'] = {
      'bucket_name': {{ .Values.filestore.gcs.bucketName | quote }},
  }
  {{- end }}

  {{- if eq .Values.filestore.backend "s3" }}
  SENTRY_OPTIONS['filestore.options'] = {
      'access_key': os.getenv("S3_ACCESS_KEY_ID", {{ .Values.filestore.s3.accessKey | default "" | quote }}),
      'secret_key': os.getenv("S3_SECRET_ACCESS_KEY", {{ .Values.filestore.s3.secretKey | default "" | quote }}),
      {{- if .Values.filestore.s3.bucketName }}
      'bucket_name': {{ .Values.filestore.s3.bucketName | quote }},
      {{- end }}
      {{- if .Values.filestore.s3.endpointUrl }}
      'endpoint_url': {{ .Values.filestore.s3.endpointUrl | quote }},
      {{- end }}
      {{- if .Values.filestore.s3.signature_version }}
      'signature_version': {{ .Values.filestore.s3.signature_version | quote }},
      {{- end }}
      {{- if .Values.filestore.s3.region_name }}
      'region_name': {{ .Values.filestore.s3.region_name | quote }},
      {{- end }}
      {{- if .Values.filestore.s3.default_acl }}
      'default_acl': {{ .Values.filestore.s3.default_acl | quote }},
      {{- end }}
      #add config params for s3
      {{- if .Values.filestore.s3.addressing_style }}
      'addressing_style': {{ .Values.filestore.s3.addressing_style | quote }},
      {{- end }}
      {{- if .Values.filestore.s3.location }}
      'location': {{ .Values.filestore.s3.location | quote }},
      {{- end }}
  }
  {{- end }}

  ##################
  # Replay Storage #
  ##################
  {{- if .Values.replay.storage.backend }}
  SENTRY_OPTIONS['replay.storage.backend'] = {{ .Values.replay.storage.backend | quote }}

  {{- if eq .Values.replay.storage.backend "filesystem" }}
  SENTRY_OPTIONS['replay.storage.options'] = {
      'location': {{ .Values.replay.storage.filesystem.path | quote }},
  }
  {{- end }}

  {{- if eq .Values.replay.storage.backend "gcs" }}
  SENTRY_OPTIONS['replay.storage.options'] = {
      'bucket_name': {{ .Values.replay.storage.gcs.bucketName | quote }},
  }
  {{- end }}

  {{- if eq .Values.replay.storage.backend "s3" }}
  {{- $replayS3 := .Values.replay.storage.s3 | default dict }}
  SENTRY_OPTIONS['replay.storage.options'] = {
      'access_key': os.getenv("REPLAY_S3_ACCESS_KEY_ID", {{ $replayS3.accessKey | default "" | quote }}),
      'secret_key': os.getenv("REPLAY_S3_SECRET_ACCESS_KEY", {{ $replayS3.secretKey | default "" | quote }}),
      {{- if $replayS3.bucketName }}
      'bucket_name': {{ $replayS3.bucketName | quote }},
      {{- end }}
      {{- if $replayS3.endpointUrl }}
      'endpoint_url': {{ $replayS3.endpointUrl | quote }},
      {{- end }}
      {{- if $replayS3.signature_version }}
      'signature_version': {{ $replayS3.signature_version | quote }},
      {{- end }}
      {{- if $replayS3.region_name }}
      'region_name': {{ $replayS3.region_name | quote }},
      {{- end }}
      {{- if $replayS3.default_acl }}
      'default_acl': {{ $replayS3.default_acl | quote }},
      {{- end }}
      {{- if $replayS3.bucket_acl }}
      'bucket_acl': {{ $replayS3.bucket_acl | quote }},
      {{- end }}
      {{- if $replayS3.addressing_style }}
      'addressing_style': {{ $replayS3.addressing_style | quote }},
      {{- end }}
      {{- if $replayS3.location }}
      'location': {{ $replayS3.location | quote }},
      {{- end }}
  }
  {{- end }}
  {{- end }}

  ###################
  # Profiling Store #
  ###################
  # The profiling team has been working on vroomrs, and it's now doing the heavy lifting.
  # The ingest-profiles container now processes profiles immediately via vroomrs and writes
  # them directly to your bucket. This streamlines the pipeline.
  #
  # NOTE: It's recommended to use an object storage backend for profiles storage
  # (for example S3-compatible storage or GCS).
  # While filesystem backend is supported (for sharing PVC between vroom and ingest-profiles),
  # it's not recommended for production use.
  {{- if .Values.filestore.profiles.backend }}
  SENTRY_OPTIONS['filestore.profiles-backend'] = {{ .Values.filestore.profiles.backend | quote }}

  {{- if eq .Values.filestore.profiles.backend "gcs" }}
  SENTRY_OPTIONS['filestore.profiles-options'] = {
      'bucket_name': {{ .Values.filestore.profiles.gcs.bucketName | quote }},
  }
  {{- end }}

  {{- if eq .Values.filestore.profiles.backend "s3" }}
  {{- $profilesS3 := .Values.filestore.profiles.s3 | default dict }}
  SENTRY_OPTIONS['filestore.profiles-options'] = {
      'access_key': os.getenv("PROFILES_S3_ACCESS_KEY_ID", {{ $profilesS3.accessKey | default "" | quote }}),
      'secret_key': os.getenv("PROFILES_S3_SECRET_ACCESS_KEY", {{ $profilesS3.secretKey | default "" | quote }}),
      {{- if $profilesS3.bucketName }}
      'bucket_name': {{ $profilesS3.bucketName | quote }},
      {{- end }}
      {{- if $profilesS3.endpointUrl }}
      'endpoint_url': {{ $profilesS3.endpointUrl | quote }},
      {{- end }}
      {{- if $profilesS3.signature_version }}
      'signature_version': {{ $profilesS3.signature_version | quote }},
      {{- end }}
      {{- if $profilesS3.region_name }}
      'region_name': {{ $profilesS3.region_name | quote }},
      {{- end }}
      {{- if $profilesS3.default_acl }}
      'default_acl': {{ $profilesS3.default_acl | quote }},
      {{- end }}
      {{- if $profilesS3.bucket_acl }}
      'bucket_acl': {{ $profilesS3.bucket_acl | quote }},
      {{- end }}
      {{- if $profilesS3.addressing_style }}
      'addressing_style': {{ $profilesS3.addressing_style | quote }},
      {{- end }}
  }
  {{- end }}

  {{- if eq .Values.filestore.profiles.backend "filesystem" }}
  SENTRY_OPTIONS['filestore.profiles-options'] = {
      'location': {{ .Values.filestore.profiles.filesystem.path | quote }},
  }
  {{- end }}
  {{- end }}

  {{- if .Values.nodestore.backend }}
  {{- if eq .Values.nodestore.backend "s3" }}
  ################
  # Node Storage #
  ################

  # Sentry uses an abstraction layer called "node storage" to store raw events.
  # Previously, it used PostgreSQL as the backend, but this didn't scale for
  # high-throughput environments. Read more about this in the documentation:
  # https://develop.sentry.dev/backend/application-domains/nodestore/
  #
  # Through this setting, you can use the provided blob storage or
  # your own S3-compatible API from your infrastructure.
  # Other backend implementations for node storage developed by the community
  # are available in public GitHub repositories.
  {{- $nodestoreS3 := .Values.nodestore.s3 | default dict }}
  SENTRY_NODESTORE = "sentry_nodestore_s3.S3PassthroughDjangoNodeStorage"
  SENTRY_NODESTORE_OPTIONS = {
      {{- if $nodestoreS3.deleteThrough }}
      "delete_through": {{ $nodestoreS3.deleteThrough }},
      {{- end }}
      {{- if $nodestoreS3.writeThrough }}
      "write_through": {{ $nodestoreS3.writeThrough }},
      {{- end }}
      {{- if $nodestoreS3.readThrough }}
      "read_through": {{ $nodestoreS3.readThrough }},
      {{- end }}
      {{- if $nodestoreS3.compression }}
      "compression": {{ $nodestoreS3.compression }},
      {{- end }}
      {{- if $nodestoreS3.endpointUrl }}
      "endpoint_url": {{ $nodestoreS3.endpointUrl | quote }},
      {{- end }}
      {{- if $nodestoreS3.bucketPath }}
      "bucket_path": {{ $nodestoreS3.bucketPath | quote }},
      {{- end }}
      {{- if $nodestoreS3.bucketName }}
      "bucket_name": {{ $nodestoreS3.bucketName | quote }},
      {{- end }}
      {{- if $nodestoreS3.regionName }}
      "region_name": {{ $nodestoreS3.regionName | quote }},
      {{- end }}
      "aws_access_key_id": os.getenv("NODESTORE_S3_ACCESS_KEY_ID", {{ $nodestoreS3.accessKeyId | default "" | quote }}),
      "aws_secret_access_key": os.getenv("NODESTORE_S3_SECRET_ACCESS_KEY", {{ $nodestoreS3.secretAccessKey | default "" | quote }}),
  }
  {{- end }}
  {{- end }}

  #########################
  # Bitbucket Integration #
  #########################

  # BITBUCKET_CONSUMER_KEY = 'YOUR_BITBUCKET_CONSUMER_KEY'
  # BITBUCKET_CONSUMER_SECRET = 'YOUR_BITBUCKET_CONSUMER_SECRET'

  #########
  # Relay #
  #########
  SENTRY_RELAY_WHITELIST_PK = []
  SENTRY_RELAY_OPEN_REGISTRATION = True

  #######################
  # OpenAi Suggestions #
  #######################

  OPENAI_API_KEY = os.getenv("OPENAI_API_KEY", "")
  if OPENAI_API_KEY:
    SENTRY_FEATURES["organizations:open-ai-suggestion"] = True

  ########################
  # JS SDK Loader Script #
  ########################
  {{- if .Values.sentry.jsSdk.setupAssets }}
  JS_SDK_LOADER_DEFAULT_SDK_URL = {{ .Values.sentry.jsSdk.defaultSdkUrl | quote }}
  {{- end }}

{{- if .Values.metrics.enabled }}
  SENTRY_METRICS_BACKEND = 'sentry.metrics.statsd.StatsdMetricsBackend'
  SENTRY_METRICS_OPTIONS = {
      'host': '{{ template "sentry.fullname" . }}-metrics',
      'port': 9125,
  }
{{- end }}

{{- if .Values.slack.existingSecret }}
  #########
  # SLACK #
  #########
  SENTRY_OPTIONS['slack.client-id'] = os.environ.get("SLACK_CLIENT_ID")
  SENTRY_OPTIONS['slack.client-secret'] = os.environ.get("SLACK_CLIENT_SECRET")
  SENTRY_OPTIONS['slack.signing-secret'] = os.environ.get("SLACK_SIGNING_SECRET")
{{- end }}

{{- if .Values.discord.existingSecret }}
  ###########
  # DISCORD #
  ###########
  SENTRY_OPTIONS['discord.application-id'] = os.environ.get("DISCORD_APPLICATION_ID")
  SENTRY_OPTIONS['discord.public-key'] = os.environ.get("DISCORD_PUBLIC_KEY")
  SENTRY_OPTIONS['discord.client-secret'] = os.environ.get("DISCORD_CLIENT_SECRET")
  SENTRY_OPTIONS['discord.bot-token'] = os.environ.get("DISCORD_BOT_TOKEN")
{{- end }}

{{- if .Values.google.existingSecret }}
  #########
  # GOOGLE #
  #########
  SENTRY_OPTIONS['auth-google.client-id'] = os.environ.get("GOOGLE_AUTH_CLIENT_ID")
  SENTRY_OPTIONS['auth-google.client-secret'] = os.environ.get("GOOGLE_AUTH_CLIENT_SECRET")
{{- end }}

{{- if .Values.github.existingSecret }}
  ##########
  # Github #
  ##########
  {{- if .Values.github.existingSecretAppIdKey }}
  # GitHub App ID must be an integer (Sentry 26.x+)
  _github_app_id = os.environ.get("GITHUB_APP_ID")
  if _github_app_id:
      SENTRY_OPTIONS['github-app.id'] = int(_github_app_id)
  {{- end }}
  {{- if .Values.github.existingSecretAppNameKey }}
  SENTRY_OPTIONS['github-app.name'] = os.environ.get("GITHUB_APP_NAME")
  {{- end }}
  SENTRY_OPTIONS['github-app.private-key'] = os.environ.get("GITHUB_APP_PRIVATE_KEY")
  SENTRY_OPTIONS['github-app.webhook-secret'] = os.environ.get("GITHUB_APP_WEBHOOK_SECRET")
  SENTRY_OPTIONS['github-app.client-id'] = os.environ.get("GITHUB_APP_CLIENT_ID")
  SENTRY_OPTIONS['github-app.client-secret'] = os.environ.get("GITHUB_APP_CLIENT_SECRET")
{{- end }}
  {{ .Values.config.sentryConfPy | nindent 2 }}
{{- end -}}

{{/*
Init container for installing sentry-nodestore-s3 package
*/}}
{{- define "sentry.initContainer.nodestore-s3" -}}
{{- if and .Values.nodestore.backend .Values.nodestore.installViaInitContainer }}
- name: install-nodestore-s3
  image: "{{ template "sentry.image" . }}"
  imagePullPolicy: {{ default "IfNotPresent" .Values.images.sentry.pullPolicy }}
  command:
    - sh
    - -c
    - |
      pip install --target=/sentry-plugins https://github.com/getsentry/sentry-nodestore-s3/archive/main.zip
  volumeMounts:
    - name: sentry-plugins
      mountPath: /sentry-plugins
  {{- if .Values.nodestore.initContainer.env }}
  env:
  {{- toYaml .Values.nodestore.initContainer.env | nindent 4 }}
  {{- end }}
{{- end }}
{{- end -}}

{{/*
Volume definition for sentry plugins
*/}}
{{- define "sentry.volume.nodestore-s3" -}}
{{- if and .Values.nodestore.backend .Values.nodestore.installViaInitContainer }}
- name: sentry-plugins
  emptyDir: {}
{{- end }}
{{- end -}}

{{/*
Volume mount for sentry plugins
*/}}
{{- define "sentry.volumeMount.nodestore-s3" -}}
{{- if and .Values.nodestore.backend .Values.nodestore.installViaInitContainer }}
- name: sentry-plugins
  mountPath: /sentry-plugins
{{- end }}
{{- end -}}

{{/*
Volume definition for replay filesystem storage
*/}}
{{- define "sentry.volume.replay-filesystem" -}}
{{- if and (eq .Values.replay.storage.backend "filesystem") .Values.replay.storage.filesystem.persistence.enabled }}
- name: sentry-replay-data
  {{- if .Values.replay.storage.filesystem.persistence.existingClaim }}
  persistentVolumeClaim:
    claimName: {{ .Values.replay.storage.filesystem.persistence.existingClaim }}
  {{- else }}
  persistentVolumeClaim:
    claimName: {{ template "sentry.fullname" . }}-replay-data
  {{- end }}
{{- end }}
{{- end -}}

{{/*
Volume mount for replay filesystem storage
*/}}
{{- define "sentry.volumeMount.replay-filesystem" -}}
{{- if and (eq .Values.replay.storage.backend "filesystem") .Values.replay.storage.filesystem.persistence.enabled }}
- name: sentry-replay-data
  mountPath: {{ .Values.replay.storage.filesystem.path }}
{{- end }}
{{- end -}}

{{/*
Environment variable for Python path to include plugins
*/}}
{{- define "sentry.env.nodestore-s3" -}}
{{- if .Values.nodestore.backend }}
{{- if .Values.nodestore.installViaInitContainer }}
- name: PYTHONPATH
  value: "/sentry-plugins"
{{- end }}
{{- if .Values.nodestore.s3.setAwsChecksumCalculationVar }}
- name: AWS_REQUEST_CHECKSUM_CALCULATION
  value: when_required
{{- end }}
{{- end }}
{{- end -}}
