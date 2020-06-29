# Sentry 10 helm charts

Sentry is a cross-platform crash reporting and aggregation platform.

This repository aims to support Sentry 10 and move out from the deprecated Helm charts official repo.

Big thanks from the maintainers of the [deprecated chart](https://github.com/helm/charts/tree/master/stable/sentry). This work has been partly inspired by it.

## How this chart works

`helm repo add sentry https://sentry-kubernetes.github.io/charts`

## Values

For now the full list of values is not documented but you can get inspired by the values.yaml specific to each directory.

## Upgrading from deprecated 9.0 -> 10.0 Chart
As this chart runs in helm 3 and also tries its best to follow on from the original Sentry chart. There are some steps that needs to be taken in order to correctly upgrade.

From the previous upgrade, make sure to get the following from your previous installation:
 - Redis Password (If Redis auth was enabled)
 - Postgresql Password
Both should be in the `secrets` of your original 9.0 release. Make a note of both of these values.

#### Upgrade Steps
Due to an issue where transferring from Helm 2 to 3. Statefulsets that use the following: `heritage: {{ .Release.Service }}` in the metadata field will error out with a `Forbidden` error during the upgrade. The only workaround is to delete the existing statefulsets (Don't worry, PVC will be retained):

> kubectl delete --all sts -n <Sentry Namespace>

Once the statefulsets are deleted. Next steps is to convert the helm release from version 2 to 3 using the helm 3 plugin:

> helm3 2to3 convert <Sentry Release Name>

Finally, it's just a case of upgrading and ensuring the correct params are used:

If Redis auth enabled:

> helm upgrade -n <Sentry namespace> <Sentry Release> . --set redis.usePassword=true --set redis.password=<Redis Password> --set postgresql.postgresqlPassword=<Postgresql Password>

If Redis auth is disabled:
> helm upgrade -n <Sentry namespace> <Sentry Release> . --set postgresql.postgresqlPassword=<Postgresql Password>

## PostgreSQL

By default, PostgreSQL is installed as part of the chart. To use an external PostgreSQL server set `postgresql.enabled` to `false` and then set `postgresql.postgresqlHost` and `postgresql.postgresqlPassword`. The other options (`postgresql.postgresqlDatabase`, `postgresql.postgresqlUsername` and `postgresql.postgresqlPort`) may also want changing from their default values.

To avoid issues when upgrade this chart, provide `postgresql.postgresqlPassword` for subsequent upgrades. This is due to an issue in the PostgreSQL chart where password will be overwritten with randomly generated passwords otherwise. See https://github.com/helm/charts/tree/master/stable/postgresql#upgrade for more detail.

## Kafka

By default, Kafka is installed as part of the chart. To use an external Kafka and zookeeper set `kafka.enabled` and `kafka.zookeeper.enabled` to `false` and then set `kafka.service.host` and `kafka.zookeeper.service.host`. The other options (`kafka.service.port` and `kafka.zookeeper.service.host`) may also want changing from their default values.

## Persistence

This chart is capable of mounting the sentry-data PV in the Sentry worker and cron pods. This feature is disabled by default, but is needed for some advanced features such as private sourcemaps.

You may enable mounting of the sentry-data PV across worker and cron pods by changing filestore.filesystem.persistence.persistentWorkers to true. If you plan on deploying Sentry containers across multiple nodes, you may need to change your PVC's access mode to ReadWriteMany and check that your PV supports mounting across multiple nodes.

## Upgrade notes

From v1 to v2, we changed the timezone of Clickhouse from Shanguai to UTC (Snuba requires it).
You'll need to execute this query on your old events (if not you'll have "no events found on them") :

```
INSERT INTO sentry_local
SELECT event_id,
       project_id,
       group_id,
       timestamp + INTERVAL 8 HOUR         AS timestamp,
       deleted,
       retention_days,
       platform,
       message,
       primary_hash,
       received + INTERVAL 8 HOUR          AS received,
       search_message,
       title,
       location,
       user_id,
       username,
       email,
       ip_address,
       geo_country_code,
       geo_region,
       geo_city,
       sdk_name,
       sdk_version,
       type,
       version,
       offset,
       partition,
       message_timestamp + INTERVAL 8 HOUR AS message_timestamp,
       os_build,
       os_kernel_version,
       device_name,
       device_brand,
       device_locale,
       device_uuid,
       device_model_id,
       device_arch,
       device_battery_level,
       device_orientation,
       device_simulator,
       device_online,
       device_charging,
       level,
       logger,
       server_name,
       transaction,
       environment,
       `sentry:release`,
       `sentry:dist`,
       `sentry:user`,
       site,
       url,
       app_device,
       device,
       device_family,
       runtime,
       runtime_name,
       browser,
       browser_name,
       os,
       os_name,
       os_rooted,
       `tags.key`,
       `tags.value`,
       _tags_flattened,
       `contexts.key`,
       `contexts.value`,
       http_method,
       http_referer,
       `exception_stacks.type`,
       `exception_stacks.value`,
       `exception_stacks.mechanism_type`,
       `exception_stacks.mechanism_handled`,
       `exception_frames.abs_path`,
       `exception_frames.filename`,
       `exception_frames.package`,
       `exception_frames.module`,
       `exception_frames.function`,
       `exception_frames.in_app`,
       `exception_frames.colno`,
       `exception_frames.lineno`,
       `exception_frames.stack_level`,
       culprit,
       sdk_integrations,
       `modules.name`,
       `modules.version`
FROM sentry_local
WHERE timestamp < toDateTime('REPLACE_ME') + INTERVAL 8 HOUR;
```

Replace REPLACE_ME with the time Sentry was upgraded at in UTC (it should suffice to grab the timestamp from the first correctly received event after the upgrade and take a second off that) in the following format yyyy-mm-dd hh:mm:ss

## Roadmap

- [X] Lint in Pull requests
- [X] Public availability through Github Pages
- [X] Automatic deployment through Github Actions
- [ ] Symbolicator deployment
- [X] Testing the chart in a production environment
- [ ] Improving the README
