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

  ################
  # File storage #
  ################
  # Uploaded media uses these `filestore` settings. The available
  # backends are either `filesystem` or `s3`.
  filestore.backend: {{ .Values.filestore.backend | quote }}
  {{- if eq .Values.filestore.backend "filesystem" }}
  filestore.options:
    location: {{ .Values.filestore.filesystem.path | quote }}
  {{ end }}
  {{- if eq .Values.filestore.backend "gcs" }}
  filestore.options:
    bucket_name: {{ .Values.filestore.gcs.bucketName | quote }}
  {{ end }}

  {{- if .Values.config.configYml }}
  {{ .Values.config.configYml | toYaml | nindent 2 }}
  {{- end }}
sentry.conf.py: |-
  from sentry.conf.server import *  # NOQA
  from distutils.util import strtobool

  BYTE_MULTIPLIER = 1024
  UNITS = ("K", "M", "G")
  def unit_text_to_bytes(text):
      unit = text[-1].upper()
      power = UNITS.index(unit) + 1
      return float(text[:-1])*(BYTE_MULTIPLIER**power)

  {{- if .Values.sourcemaps.enabled }}
  CACHES = {
      "default": {
          "BACKEND": "django.core.cache.backends.memcached.PyMemcacheCache",
          "LOCATION": [
              "{{ template "sentry.fullname" . }}-memcached:11211"
          ],
          "TIMEOUT": 3600,
          "OPTIONS": {"ignore_exc": True}
      }
  }
  {{- end }}

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

  #########
  # Queue #
  #########

  # See https://docs.getsentry.com/on-premise/server/queue/ for more
  # information on configuring your queue broker and workers. Sentry relies
  # on a Python framework called Celery to manage queues.

  {{- if or (.Values.rabbitmq.enabled) (.Values.rabbitmq.host) }}
  BROKER_URL = os.environ.get("BROKER_URL", "amqp://{{ .Values.rabbitmq.auth.username }}:{{ .Values.rabbitmq.auth.password }}@{{ template "sentry.rabbitmq.host" . }}:5672/{{ .Values.rabbitmq.vhost }}")
  {{- else if $redisPass }}
  BROKER_URL = os.environ.get("BROKER_URL", "{{ $redisProto }}://:{{ $redisPass }}@{{ $redisHost }}:{{ $redisPort }}/{{ $redisDb }}")
  {{- else if and (not .Values.externalRedis.existingSecret) (not .Values.redis.auth.existingSecret)}}
  BROKER_URL = os.environ.get("BROKER_URL", "{{ $redisProto }}://{{ $redisHost }}:{{ $redisPort }}/{{ $redisDb }}")
  {{- end }}

  #########
  # Cache #
  #########

  # Sentry currently utilizes two separate mechanisms. While CACHES is not a
  # requirement, it will optimize several high throughput patterns.

  # CACHES = {
  #     "default": {
  #         "BACKEND": "django.core.cache.backends.memcached.MemcachedCache",
  #         "LOCATION": ["memcached:11211"],
  #         "TIMEOUT": 3600,
  #     }
  # }

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
              {{ end -}}
              {{- if .Values.sentry.features.orgSubdomains }}
              "organizations:org-ingest-subdomains",
              {{ end -}}
              "organizations:discover",
              "organizations:global-views",
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
              # Performance/Tracing/Spans related flags
              "organizations:performance-view",
              "organizations:visibility-explore-view",
              "organizations:transaction-metrics-extraction",
              "organizations:indexed-spans-extraction",
              "organizations:insights-entry-points",
              "organizations:insights-initial-modules",
              "organizations:insights-addon-modules",
              "organizations:standalone-span-ingestion",
              "organizations:starfish-mobile-appstart",
              "projects:span-metrics-extraction",
              "projects:span-metrics-extraction-addons",
              
              # flags added in this chart
              "organizations:trace-view-load-more",
              "organizations:trace-tabs-ui",
              "organizations:trace-view-linked-traces",
              "organizations:span-stats",
              "organizations:visibility-explore-range-high",
          )
          {{- end }}
          {{- if .Values.sentry.features.enableSessionReplay}}
          + (
              # Session Replay related flags
              "organizations:session-replay",
              
              # flags added in this chart
              "organizations:session-replay-ui",
              "organizations:session-replay-issue-emails",
              "organizations:session-replay-recording-scrubbing",
              "organizations:session-replay-slack-new-issue",
          )
          {{- end }}
          {{- if .Values.sentry.features.enableFeedback }}
          + (
              # User Feedback related flags
              "organizations:user-feedback-ui",
          )
          {{- end }}
          {{- if .Values.sentry.features.enableProfiling }}
          + (
              # Profiling related flags
              "organizations:profiling",
              "organizations:profiling-view",
              # Continuous Profiling related flags
              "organizations:continuous-profiling",
              "organizations:continuous-profiling-stats",
          )
          {{- end }}
          {{- if .Values.sentry.features.enableUptime }}
          + (
              # Uptime Monitoring related flags
              "organizations:uptime",
              "organizations:uptime-create-issues",
          )
          {{- end }}
          + (
              # Flags enabled in this chart but not present in https://github.com/getsentry/self-hosted/blob/master/sentry/sentry.conf.example.py
              "organizations:related-events",
              "organizations:reprocessing-v2",
              "organizations:set-grouping-config",
              "organizations:onboarding",
              "projects:similarity-indexing",
              "projects:similarity-view",
          )
          + (
              # Custom features from values
              {{- if .Values.sentry.customFeatures }}
              {{- range $CustomFeature := .Values.sentry.customFeatures }}
              "{{ $CustomFeature}}",
              {{- end }}
              {{- end }}
          )
      }
  )

  #######################
  # Email Configuration #
  #######################
  SENTRY_OPTIONS['mail.backend'] = os.getenv("SENTRY_EMAIL_BACKEND", {{ .Values.mail.backend | quote }})
  SENTRY_OPTIONS['mail.use-tls'] = bool(strtobool(os.getenv("SENTRY_EMAIL_USE_TLS", {{ .Values.mail.useTls | quote }})))
  SENTRY_OPTIONS['mail.use-ssl'] = bool(strtobool(os.getenv("SENTRY_EMAIL_USE_SSL", {{ .Values.mail.useSsl | quote }})))
  SENTRY_OPTIONS['mail.username'] = os.getenv("SENTRY_EMAIL_USERNAME", {{ .Values.mail.username | quote }})
  SENTRY_OPTIONS['mail.password'] = os.getenv("SENTRY_EMAIL_PASSWORD", "")
  SENTRY_OPTIONS['mail.port'] = int(os.getenv("SENTRY_EMAIL_PORT", {{ .Values.mail.port | quote }}))
  SENTRY_OPTIONS['mail.host'] = os.getenv("SENTRY_EMAIL_HOST", {{ .Values.mail.host | quote }})
  SENTRY_OPTIONS['mail.from'] = os.getenv("SENTRY_EMAIL_FROM", {{ .Values.mail.from | quote }})

  #######################
  # Filestore S3 Configuration #
  #######################
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
      #add comfig params for s3
      {{- if .Values.filestore.s3.addressing_style }}
      'addressing_style': {{ .Values.filestore.s3.addressing_style | quote }},
      {{- end }}
      {{- if .Values.filestore.s3.location }}
      'location': {{ .Values.filestore.s3.location | quote }},
      {{- end }}
  }
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

  #########
  # Tasks #
  #########
  # Disable taskworker and continue using celery.
  SENTRY_OPTIONS["taskworker.enabled"] = False

  #######################
  # OpenAi Suggestions #
  #######################

  OPENAI_API_KEY = os.getenv("OPENAI_API_KEY", "")
  if OPENAI_API_KEY:
    SENTRY_FEATURES["organizations:open-ai-suggestion"] = True

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
  SENTRY_OPTIONS['github-app.private-key'] = os.environ.get("GITHUB_APP_PRIVATE_KEY")
  SENTRY_OPTIONS['github-app.webhook-secret'] = os.environ.get("GITHUB_APP_WEBHOOK_SECRET")
  SENTRY_OPTIONS['github-app.client-id'] = os.environ.get("GITHUB_APP_CLIENT_ID")
  SENTRY_OPTIONS['github-app.client-secret'] = os.environ.get("GITHUB_APP_CLIENT_SECRET")
{{- end }}
  {{ .Values.config.sentryConfPy | nindent 2 }}
{{- end -}}
