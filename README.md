# Sentry helm charts

Sentry is a cross-platform crash reporting and aggregation platform.

This repository aims to support Sentry >=10 and move out from the deprecated Helm charts official repo.

Big thanks to the maintainers of the [deprecated chart](https://github.com/helm/charts/tree/master/stable/sentry). This work has been partly inspired by it.

## How this chart works

`helm repo add sentry https://sentry-kubernetes.github.io/charts`

## Values

For now the full list of values is not documented but you can get inspired by the values.yaml specific to each directory.

## Upgrading from 19.x.x version of this Chart to 20.x.x

Bumped dependencies:
- kafka > 22.1.3 - now supports Kraft. Note that the upgrade is breaking and that you have to start a new kafka from scratch to use it.

Example:

```
kafka:
  zookeeper:
    enabled: false
  kraft:
    enabled: true
```


## Upgrading from 18.x.x version of this Chart to 19.x.x

Chart dependencies has been upgraded because of sentry requirements. 
Changes:
- The minimum required version of Postgresql is 14.5 (works with 15.x too)

Bumped dependencies:
- postgresql > 12.5.1 - latest wersion of chart with postgres 15


## Upgrading from 17.x.x version of this Chart to 18.x.x

If Kafka is complaining about unknown or missing topic, please connect to kafka-0 and run 

`/opt/bitnami/kafka/bin/kafka-topics.sh --create --topic ingest-replay-recordings --bootstrap-server localhost:9092`


## Upgrading from 16.x.x version of this Chart to 17.x.x

Sentry version from 22.10.0 onwards should be using chart 17.x.x

- post process forwarder events and transactions topics are splitted in Sentry 22.10.0

You can delete the deployment "sentry-post-process-forward" as it's no longer needed.

`sentry-worker` may failed to start by [#774](https://github.com/sentry-kubernetes/charts/issues/774).
If you encountered this issue, please reset `counters-0`, `triggers-0` queues.


## Upgrading from 15.x.x version of this Chart to 16.x.x

system.secret-key is removed

See https://github.com/sentry-kubernetes/charts/tree/develop/sentry#sentry-secret-key


## Upgrading from 14.x.x version of this Chart to 15.x.x

Chart dependencies has been upgraded because of bitnami charts removal. 
Changes:
- `nginx.service.port: 80` > `nginx.service.ports.http: 80`
- `kafka.service.port` > `kafka.service.ports.client`

Bumped dependencies:
- redis > 16.12.1 - latest version of chart
- kafka > 16.3.2 - chart aligned with zookeeper dependency, upgraded kafka to 3.11
- rabbit > 8.32.2 - latest 3.9.* image version of chart
- postgresql > 10.16.2 - latest wersion of chart with postgres 11
- nginx > 12.0.4 - latest version of chart

## Upgrading from 13.x.x version of this Chart to 14.0.0

ClickHouse was reconfigured with sharding and replication in-mind, If you are using external ClickHouse, you don't need to do anything.

**WARNING**: You will lose current event data<br>
Otherwise, you should delete the old ClickHouse volumes in-order to upgrade to this version.


## Upgrading from 12.x.x version of this Chart to 13.0.0

The service annotions have been moved from the `service` section to the respective service's service sub-section. So what was:

```yaml
service:
  annotations:
    alb.ingress.kubernetes.io/healthcheck-path: /_health/
    alb.ingress.kubernetes.io/healthcheck-port: traffic-port
```

will now be set per service:

```yaml
sentry:
  web:
    service:
      annotations:
        alb.ingress.kubernetes.io/healthcheck-path: /_health/
        alb.ingress.kubernetes.io/healthcheck-port: traffic-port

relay:
  service:
    annotations:
      alb.ingress.kubernetes.io/healthcheck-path: /api/relay/healthcheck/ready/
      alb.ingress.kubernetes.io/healthcheck-port: traffic-port
```


## Upgrading from 10.x.x version of this Chart to 11.0.0

If you were using clickhouse tabix externally, we disabled it per default.

## Upgrading from 9.x.x version of this Chart to 10.0.0

If you were using clickhouse ImagePullSecrets, [we unified](https://github.com/sentry-kubernetes/charts/commit/573ca29d03bf2c044004c1aa387f652a36ada23a) the way it's used.

## Upgrading from 8.x.x version of this Chart to 9.0.0

to simplify 1st time installations, backup value on clickhouse has been changed to false.

clickhouse.clickhouse.configmap.remote_servers.replica.backup

## Upgrading from 7.x.x version of this Chart to 8.0.0

- the default value of features.orgSubdomains is now "false"

## Upgrading from 6.x.x version of this Chart to 7.0.0

- the default mode of relay is now "proxy". You can change it through the values.yaml file
- we removed the `githubSso` variable for the oauth github configuration. It was using the old environment variable, that doesn't work with Sentry anymore. Just use the common github.xxxx configuration for both oauth & the application integration.

## Upgrading from 5.x.x version of this Chart to 6.0.0

- The sentry.configYml value is now in a real yaml format
- If you were previously using `relay.asHook`, the value is now `asHook`

## Upgrading from 4.x.x version of this Chart to 5.0.0

As Relay is now part of this chart your need to make sure you enable either Nginx or the Ingress. Please read the next paragraph for more informations.

If you are using an ingress gateway (like istio), you have to change your inbound path from sentry-web to nginx.

## NGINX and/or Ingress

By default, NGINX is enabled to allow sending the incoming requests to [Sentry Relay](https://getsentry.github.io/relay/) or the Django backend depending on the path. When Sentry is meant to be exposed outside of the Kubernetes cluster, it is recommended to disable NGINX and let the Ingress do the same. It's recommended to go with the go to Ingress Controller, [NGINX Ingress](https://kubernetes.github.io/ingress-nginx/) but others should work as well.

Note: if you are using NGINX Ingress, please set this annotation on your ingress : nginx.ingress.kubernetes.io/use-regex: "true".
If you are using `additionalHostNames` the `nginx.ingress.kubernetes.io/upstream-vhost` annotation might also come in handy.
It sets the `Host` header to the value you provide to avoid CSRF issues.

### Letsencrypt on NGINX Ingress Controller
```
nginx:
  ingress:
    annotations:
      cert-manager.io/cluster-issuer: "letsencrypt-prod"
    enabled: true
    hostname: fqdn
    ingressClassName: "nginx"
    tls: true
```

## Clickhouse warning

Snuba only supports a UTC timezone for Clickhouse. Please keep the initial value!

## Upgrading from 3.1.0 version of this Chart to 4.0.0

Following Helm Chart best practices the new version introduces some breaking changes, all configuration for external
resources moved to separate config branches: `externalClickhouse`, `externalKafka`, `externalRedis`, `externalPostgresql`.

Here is a mapping table of old values and new values:

| Before                          | After                         |
| ------------------------------- | ----------------------------- |
| `postgresql.postgresqlHost`     | `externalPostgresql.host`     |
| `postgresql.postgresqlPort`     | `externalPostgresql.port`     |
| `postgresql.postgresqlUsername` | `externalPostgresql.username` |
| `postgresql.postgresqlPassword` | `externalPostgresql.password` |
| `postgresql.postgresqlDatabase` | `externalPostgresql.database` |
| `postgresql.postgresSslMode`    | `externalPostgresql.sslMode`  |
| `redis.host`                    | `externalRedis.host`          |
| `redis.port`                    | `externalRedis.port`          |
| `redis.password`                | `externalRedis.password`      |

## Upgrading from deprecated 9.0 -> 10.0 Chart

As this chart runs in helm 3 and also tries its best to follow on from the original Sentry chart. There are some steps that needs to be taken in order to correctly upgrade.

From the previous upgrade, make sure to get the following from your previous installation:

- Redis Password (If Redis auth was enabled)
- PostgreSQL Password
  Both should be in the `secrets` of your original 9.0 release. Make a note of both of these values.

#### Upgrade Steps

Due to an issue where transferring from Helm 2 to 3. Statefulsets that use the following: `heritage: {{ .Release.Service }}` in the metadata field will error out with a `Forbidden` error during the upgrade. The only workaround is to delete the existing statefulsets (Don't worry, PVC will be retained):

> `kubectl delete --all sts -n <Sentry Namespace>`

Once the statefulsets are deleted. Next steps is to convert the helm release from version 2 to 3 using the helm 3 plugin:

> `helm3 2to3 convert <Sentry Release Name>`

Finally, it's just a case of upgrading and ensuring the correct params are used:

If Redis auth enabled:

> `helm upgrade -n <Sentry namespace> <Sentry Release> . --set redis.usePassword=true --set redis.password=<Redis Password> --set postgresql.postgresqlPassword=<Postgresql Password>`

If Redis auth is disabled:

> `helm upgrade -n <Sentry namespace> <Sentry Release> . --set postgresql.postgresqlPassword=<Postgresql Password>`

Please also follow the steps for Major version 3 to 4 migration

## PostgreSQL

By default, PostgreSQL is installed as part of the chart. To use an external PostgreSQL server set `postgresql.enabled` to `false` and then set `postgresql.postgresHost` and `postgresql.postgresqlPassword`. The other options (`postgresql.postgresqlDatabase`, `postgresql.postgresqlUsername` and `postgresql.postgresqlPort`) may also want changing from their default values.

To avoid issues when upgrade this chart, provide `postgresql.postgresqlPassword` for subsequent upgrades. This is due to an issue in the PostgreSQL chart where password will be overwritten with randomly generated passwords otherwise. See https://github.com/helm/charts/tree/master/stable/postgresql#upgrade for more detail.

## Persistence

This chart is capable of mounting the sentry-data PV in the Sentry worker and cron pods. This feature is disabled by default, but is needed for some advanced features such as private sourcemaps.

You may enable mounting of the sentry-data PV across worker and cron pods by changing filestore.filesystem.persistence.persistentWorkers to true. If you plan on deploying Sentry containers across multiple nodes, you may need to change your PVC's access mode to ReadWriteMany and check that your PV supports mounting across multiple nodes.

## Roadmap

- [x] Lint in Pull requests
- [x] Public availability through Github Pages
- [x] Automatic deployment through Github Actions
- [ ] Symbolicator deployment
- [x] Testing the chart in a production environment
- [ ] Improving the README
