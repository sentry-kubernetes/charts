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
            "organizations:advanced-search",
            "organizations:anomaly-detection-alerts",
            "organizations:app-store-connect-multiple",
            "organizations:change-alerts",
            "organizations:codecov-integration",
            "organizations:crash-rate-alerts",
            "organizations:custom-symbol-sources",
            "organizations:dashboards-basic",
            "organizations:dashboards-edit",
            "organizations:data-forwarding",
            "organizations:discover-basic",
            "organizations:discover-query",
            "organizations:dynamic-sampling",
            "organizations:event-attachments",
            "organizations:incidents",
            "organizations:integrations-alert-rule",
            "organizations:integrations-chat-unfurl",
            "organizations:integrations-codeowners",
            "organizations:integrations-event-hooks",
            "organizations:integrations-enterprise-alert-rule",
            "organizations:integrations-enterprise-incident-management",
            "organizations:integrations-incident-management",
            "organizations:integrations-issue-basic",
            "organizations:integrations-issue-sync",
            "organizations:integrations-stacktrace-link",
            "organizations:integrations-ticket-rules",
            "organizations:metric-alert-chartcuterie",
            "organizations:performance-view",
            "organizations:profiling-view",
            "organizations:relay",
            "organizations:remote-config",
            "organizations:session-replay",
            "organizations:spans-usage-tracking",
            "organizations:sso-basic",
            "organizations:sso-saml2",
            "organizations:span-stats",
            "organizations:team-insights",
            "organizations:team-roles",
            "organizations:uptime",
            "organizations:continuous-profiling-billing",
            "organizations:on-demand-metrics-prefill",
            "organizations:custom-metrics",
            "organizations:sentry-pride-logo-footer",
            "organizations:seer-based-priority",
            "organizations:integrations-vercel",
            "organizations:integrations-scm-multi-org",
            "organizations:issue-views",
            "projects:data-forwarding",
            "projects:rate-limits",
            "projects:custom-inbound-filters",
            "projects:discard-groups",
            "projects:servicehooks"
          )

          {{- if .Values.sentry.features.orgSubdomains }}
          + ("organizations:org-ingest-subdomains")
          {{ end -}}

          + (
          "auth:register",
          "organizations:create",
          "relocation:enabled",
          "organizations:alert-allow-indexed",
          "organizations:alert-crash-free-metrics",
          "organizations:anomaly-detection-eap",
          "organizations:anr-analyze-frames",
          "organizations:api-organization_events-rate-limit-reduced-rollout",
          "organizations:auth-v2-merge-users",
          "organizations:auto-enable-codecov",
          "organizations:detailed-data-for-seer",
          "organizations:autofix-seer-preferences",
          "organizations:chonk-ui",
          "organizations:chonk-ui-feedback",
          "organizations:codecov-ui",
          "organizations:command-menu-v2",
          "organizations:csharp-open-pr-comments",
          "organizations:go-open-pr-comments",
          "organizations:continuous-profiling",
          "organizations:continuous-profiling-beta",
          "organizations:continuous-profiling-beta-ui",
          "organizations:continuous-profiling-stats",
          "projects:continuous-profiling-vroomrs-processing",
          "projects:transaction-profiling-vroomrs-processing",
          "organizations:profiling-flamegraph-use-increased-chunks-query-strategy",
          "organizations:daily-summary",
          "organizations:dashboards-import",
          "organizations:dashboards-mep",
          "organizations:dashboards-metrics-transition",
          "organizations:dashboards-starred-reordering",
          "organizations:dashboards-widget-builder-redesign",
          "organizations:dashboards-use-widget-table-visualization",
          "organizations:data-secrecy",
          "organizations:data-secrecy-v2",
          "organizations:device-class-synthesis",
          "organizations:device-classification",
          "organizations:discover",
          "organizations:discover-saved-queries-deprecation",
          "organizations:discover-cell-actions-v2",
          "organizations:ds-org-recalibration",
          "organizations:dynamic-sampling-custom",
          "organizations:dynamic-sampling-minimum-sample-rate",
          "organizations:escalating-issues-v2",
          "organizations:escalating-metrics-backend",
          "organizations:expose-migrated-discover-queries",
          "organizations:gen-ai-features",
          "organizations:gen-ai-explore-traces",
          "organizations:gen-ai-explore-traces-consent-ui",
          "organizations:gen-ai-consent",
          "organizations:gitlab-disable-on-broken",
          "organizations:global-views",
          "organizations:increased-issue-owners-rate-limit",
          "organizations:indexed-spans-extraction",
          "organizations:integrations-deployment",
          "organizations:integrations-feature-flag-integration",
          "organizations:invite-billing",
          "organizations:invite-members",
          "organizations:invite-members-rate-limits",
          "organizations:issue-details-lifetime-stats",
          "organizations:issue-details-streamline-enforce",
          "organizations:issue-detection-sort-spans",
          "organizations:issue-search-allow-postgres-only-search",
          "organizations:issue-taxonomy",
          "organizations:metric-issue-poc",
          "projects:metric-issue-creation",
          "organizations:issue-open-periods",
          "organizations:mep-rollout-flag",
          "organizations:mep-use-default-tags",
          "organizations:disable-clustering-setting",
          "organizations:migrate-azure-devops-integration",
          "organizations:minute-resolution-sessions",
          "organizations:mobile-cpu-memory-in-transactions",
          "organizations:mobile-vitals",
          "organizations:more-fast-alerts",
          "organizations:more-slow-alerts",
          "organizations:more-workflows",
          "organizations:navigation-sidebar-v2",
          "organizations:new-page-filter",
          "organizations:agents-insights",
          "organizations:mcp-insights",
          "organizations:on-demand-metrics-extraction",
          "organizations:on-demand-metrics-extraction-experimental",
          "organizations:on-demand-metrics-extraction-widgets",
          "organizations:on-demand-metrics-query-spec-version-two",
          "organizations:new-organization-member-invite",
          "organizations:on-demand-metrics-ui",
          "organizations:on-demand-metrics-ui-widgets",
          "organizations:onboarding",
          "organizations:ownership-size-limit-large",
          "organizations:ownership-size-limit-xlarge",
          "organizations:project-creation-games-tab",
          "organizations:performance-calculate-mobile-perf-score-relay",
          "organizations:performance-change-explorer",
          "organizations:performance-chart-interpolation",
          "organizations:performance-discover-dataset-selector",
          "organizations:deprecate-discover-widget-type",
          "organizations:performance-discover-widget-split-override-save",
          "organizations:performance-discover-widget-split-ui",
          "organizations:performance-discover-get-custom-measurements-reduced-range",
          "organizations:performance-issues-all-events-tab",
          "organizations:performance-issues-search",
          "organizations:performance-issues-spans",
          "organizations:performance-mep-bannerless-ui",
          "organizations:performance-mep-reintroduce-histograms",
          "organizations:performance-metrics-backed-transaction-summary",
          "organizations:performance-new-trends",
          "organizations:performance-new-widget-designs",
          "organizations:performance-onboarding-checklist",
          "organizations:performance-queries-mongodb-extraction",
          "organizations:performance-remove-metrics-compatibility-fallback",
          "organizations:performance-span-histogram-view",
          "organizations:performance-trace-details",
          "organizations:performance-trace-explorer",
          "organizations:performance-sentry-conventions-fields",
          "organizations:performance-spans-fields-stats",
          "organizations:performance-tracing-without-performance",
          "organizations:performance-transaction-name-only-search",
          "organizations:performance-transaction-name-only-search-indexed",
          "organizations:performance-transaction-summary-cleanup",
          "organizations:performance-transaction-summary-eap",
          "organizations:performance-otel-friendly-ui",
          "organizations:performance-spans-new-ui",
          "organizations:performance-use-metrics",
          "organizations:performance-vitals-standalone-cls-lcp",
          "organizations:performance-web-vitals-issues",
          "organizations:performance-default-explore-queries",
          "organizations:performance-spans-suspect-attributes",
          "organizations:performance-transaction-deprecation-alerts",
          "organizations:preprod-artifact-assemble",
          "organizations:preprod-frontend-routes",
          "organizations:relay-playstation-ingestion",
          "organizations:prevent-flows-poc",
          "organizations:profiling",
          "organizations:profiling-beta",
          "organizations:profiling-sdks",
          "organizations:profiling-deprecate-sdks",
          "organizations:profiling-browser",
          "organizations:profiling-differential-flamegraph-page",
          "organizations:profiling-flamegraph-always-use-direct-chunks",
          "organizations:profiling-global-suspect-functions",
          "organizations:profiling-function-trends",
          "organizations:profiling-summary-redesign",
          "organizations:project-event-date-limit",
          "organizations:project-templates",
          "organizations:related-events",
          "organizations:release-comparison-performance",
          "organizations:replay-ai-summaries",
          "organizations:replay-list-select",
          "organizations:reprocessing-v2",
          "organizations:resolve-in-upcoming-release",
          "organizations:revoke-org-auth-on-slug-rename",
          "organizations:sdk-crash-detection",
          "organizations:seer-explorer",
          "organizations:search-query-builder-raw-search-replacement",
          "organizations:search-query-builder-wildcard-operators",
          "organizations:session-replay-issue-emails",
          "organizations:session-replay-video-disabled",
          "organizations:session-replay-recording-scrubbing",
          "organizations:session-replay-slack-new-issue",
          "organizations:session-replay-ui",
          "organizations:init-sentry-toolbar",
          "organizations:sentry-toolbar-ui",
          "organizations:feature-flag-cta",
          "organizations:feature-flag-distribution-flyout",
          "organizations:feature-flag-suspect-flags",
          "organizations:issues-suspect-tags",
          "organizations:suspect-scores-sandbox-ui",
          "organizations:insights-session-health-tab-ui",
          "organizations:set-grouping-config",
          "organizations:sso-saml2-slo",
          "organizations:insights-entry-points",
          "organizations:insights-initial-modules",
          "organizations:insights-addon-modules",
          "organizations:insights-query-date-range-limit",
          "organizations:insights-use-eap",
          "organizations:insights-modules-use-eap",
          "organizations:insights-overview-use-eap",
          "organizations:insights-chart-actions",
          "organizations:insights-alerts",
          "organizations:insights-related-issues-table",
          "organizations:insights-mobile-screens-module",
          "organizations:insights-performance-landing-removal",
          "organizations:sentry-app-webhook-requests",
          "organizations:standalone-span-ingestion",
          "organizations:starfish-mobile-appstart",
          "organizations:starfish-mobile-ui-module",
          "organizations:starfish-view",
          "organizations:statistical-detectors-rca-spans-only",
          "organizations:symbol-sources",
          "organizations:grouptombstones-hit-counter",
          "organizations:tag-key-sample-n",
          "organizations:team-workflow-notifications",
          "organizations:trace-view-load-more",
          "organizations:trace-view-v1",
          "organizations:trace-view-linked-traces",
          "organizations:tracing-onboarding-new-ui",
          "organizations:trace-view-quota-exceeded-banner",
          "organizations:trace-spans-format",
          "organizations:trace-view-admin-ui",
          "organizations:trace-view-span-links",
          "organizations:trace-tabs-ui",
          "organizations:traces-onboarding-guide",
          "organizations:traces-schema-hints",
          "organizations:transaction-metrics-extraction",
          "organizations:transaction-name-mark-scrubbed-as-sanitized",
          "organizations:transaction-name-normalize",
          "organizations:trigger-autofix-on-issue-summary",
          "organizations:unlimited-auto-triggered-autofix-runs",
          "organizations:uptime-automatic-hostname-detection",
          "organizations:uptime-automatic-subscription-creation",
          "organizations:view-hierarchy-scrubbing",
          "organizations:uptime-create-issues",
          "organizations:uptime-detailed-logging",
          "organizations:uptime-detector-handler",
          "organizations:uptime-detector-create-issues",
          "organizations:uptime-eap-results",
          "organizations:uptime-eap-uptime-results-query",
          "organizations:use-metrics-layer",
          "organizations:user-feedback-ai-summaries",
          "organizations:user-feedback-spam-ingest",
          "organizations:user-feedback-ui",
          "organizations:view-hierarchies-options-dev",
          "organizations:visibility-explore-aggregate-editor",
          "organizations:visibility-explore-equations",
          "organizations:visibility-dashboards-equations",
          "organizations:visibility-explore-view",
          "organizations:visibility-explore-range-high",
          "organizations:visibility-explore-range-medium",
          "organizations:enforce-stacked-navigation",
          "organizations:workflow-engine-process-activity",
          "organizations:workflow-engine-issue-alert-dual-write",
          "organizations:workflow-engine-process-metric-issue-workflows",
          "organizations:workflow-engine-process-workflows",
          "organizations:workflow-engine-single-process-workflows",
          "organizations:workflow-engine-process-workflows-logs",
          "organizations:workflow-engine-trigger-actions",
          "organizations:workflow-engine-metric-alert-dual-processing-logs",
          "organizations:workflow-engine-metric-alert-dual-write",
          "organizations:workflow-engine-metric-alert-processing",
          "organizations:ingest-through-trusted-relays-only",
          "organizations:workflow-engine-ui",
          "organizations:workflow-engine-ui-links",
          "organizations:workflow-engine-rule-serializers",
          "organizations:event-unique-user-frequency-condition-with-conditions",
          "organizations:dynamic-sampling-spans",
          "organizations:ourlogs-enabled",
          "organizations:ourlogs-ingestion",
          "organizations:ourlogs-calculated-byte-count",
          "organizations:ourlogs-meta-attributes",
          "organizations:ourlogs-stats",
          "organizations:ourlogs-visualize-sidebar",
          "organizations:ourlogs-dashboards",
          "organizations:ourlogs-alerts",
          "organizations:ourlogs-live-refresh",
          "organizations:ourlogs-infinite-scroll",
          "organizations:ourlogs-replay-ui",
          "organizations:jira-per-project-statuses",
          "organizations:jira-paginated-projects",
          "organizations:single-trace-summary",
          "organizations:github-multi-org",
          "organizations:github-multi-org-upsell-modal",
          "projects:transaction-name-clustering-disabled",
          "projects:alert-filters",
          "projects:discard-transaction",
          "projects:error-upsampling",
          "projects:first-event-severity-calculation",
          "projects:similarity-embeddings",
          "projects:similarity-indexing",
          "projects:similarity-view",
          "projects:span-metrics-extraction",
          "projects:span-metrics-extraction-addons",
          "projects:relay-otel-endpoint",
          "projects:use-eap-spans-for-metrics-explorer",
          "projects:num-events-issue-debugging",
          "projects:plugins",
          "projects:profiling-ingest-unsampled-profiles",
          "projects:project-detail-apple-app-hang-rate",
          "organizations:scoped-partner-oauth",
          "organizations:tempest-access" )
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
