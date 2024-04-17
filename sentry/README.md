# Install

## Add repo

```
helm repo add sentry https://sentry-kubernetes.github.io/charts
```

## Without overrides

```
helm install sentry sentry/sentry
```

## With your own values file

```
helm install sentry sentry/sentry -f values.yaml
```

# Upgrade

Read the upgrade guide before upgrading to major versions of the chart.
[Upgrade Guide](docs/UPGRADE.md)

## Configuration

The following table lists the configurable parameters of the Sentry chart and their default values.

Note: this table is incomplete, so have a look at the values.yaml in case you miss something

| Parameter                                     | Description                                                                                                                                                         | Default                        |
| :-------------------------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------ | :----------------------------- |
| `user.create`                                 | if `true`, creates a default admin user defined from `email` and `password`                                                                                         | `true`                         |
| `user.email`                                  | Admin user email                                                                                                                                                    | `admin@sentry.local`           |
| `user.password`                               | Admin user password                                                                                                                                                 | `aaaa`                         |
| `hooks.dbCheck.enabled`                             | Enable Sentry database check job                                                                                                                                                    | `true`                        |
| `hooks.dbInit.enabled`                             | Enable Sentry database init job                                                                                                                                                    | `true`                        |
| `hooks.snubaInit.enabled`                             | Enable Snuba database init job                                                                                                                                                    | `true`                        |
| `hooks.snubaMigrate.enabled`                             | Enable Snuba migration  job                                                                                                                                                    | `true`                        |
| `ingress.enabled`                             | Enabling Ingress                                                                                                                                                    | `false`                        |
| `ingress.regexPathStyle`                      | Allows setting the style the regex paths are rendered in the ingress for the ingress controller in use. Possible values are `nginx`, `aws-alb`, `gke` and `traefik` | `nginx`                        |
| `nginx.enabled`                               | Enabling NGINX                                                                                                                                                      | `true`                         |
| `metrics.enabled`                             | if `true`, enable Prometheus metrics                                                                                                                                | `false`                        |
| `metrics.image.repository`                    | Metrics exporter image repository                                                                                                                                   | `prom/statsd-exporter`         |
| `metrics.image.tag`                           | Metrics exporter image tag                                                                                                                                          | `v0.10.5`                      |
| `metrics.image.PullPolicy`                    | Metrics exporter image pull policy                                                                                                                                  | `IfNotPresent`                 |
| `metrics.nodeSelector`                        | Node labels for metrics pod assignment                                                                                                                              | `{}`                           |
| `metrics.tolerations`                         | Toleration labels for metrics pod assignment                                                                                                                        | `[]`                           |
| `metrics.affinity`                            | Affinity settings for metrics                                                                                                                                       | `{}`                           |
| `metrics.resources`                           | Metrics resource requests/limit                                                                                                                                     | `{}`                           |
| `metrics.service.annotations`                 | annotations for Prometheus metrics service                                                                                                                          | `{}`                           |
| `metrics.service.clusterIP`                   | cluster IP address to assign to service (set to `"-"` to pass an empty value)                                                                                       | `nil`                          |
| `metrics.service.omitClusterIP`               | (Deprecated) To omit the `clusterIP` from the metrics service                                                                                                       | `false`                        |
| `metrics.service.externalIPs`                 | Prometheus metrics service external IP addresses                                                                                                                    | `[]`                           |
| `metrics.service.additionalLabels`            | labels for metrics service                                                                                                                                          | `{}`                           |
| `metrics.service.loadBalancerIP`              | IP address to assign to load balancer (if supported)                                                                                                                | `""`                           |
| `metrics.service.loadBalancerSourceRanges`    | list of IP CIDRs allowed access to load balancer (if supported)                                                                                                     | `[]`                           |
| `metrics.service.servicePort`                 | Prometheus metrics service port                                                                                                                                     | `9913`                         |
| `metrics.service.type`                        | type of Prometheus metrics service to create                                                                                                                        | `ClusterIP`                    |
| `metrics.serviceMonitor.enabled`              | Set this to `true` to create ServiceMonitor for Prometheus operator                                                                                                 | `false`                        |
| `metrics.serviceMonitor.additionalLabels`     | Additional labels that can be used so ServiceMonitor will be discovered by Prometheus                                                                               | `{}`                           |
| `metrics.serviceMonitor.honorLabels`          | honorLabels chooses the metric's labels on collisions with target labels.                                                                                           | `false`                        |
| `metrics.serviceMonitor.namespace`            | namespace where servicemonitor resource should be created                                                                                                           | `the same namespace as sentry` |
| `metrics.serviceMonitor.scrapeInterval`       | interval between Prometheus scraping                                                                                                                                | `30s`                          |
| `relay.enabled`       | Enable Relay                                                                                                                                | `true`                          |
| `sentry.billingMetricsConsumer.enabled`       | Enable Sentry billing metrics                                                                                                                                | `true`                          |
| `sentry.cron.enabled`       | Enable Sentry cron                                                                                                                                | `true`                          |
| `sentry.genericMetricsConsumer.enabled`       | Enable Sentry generic metrics consumer                                                                                                                                | `true`                          |
| `sentry.ingestConsumer.enabled`       | Enable Sentry ingest consumer attachments, events, transactions                                                                                                                                | `true`                          |
| `sentry.ingestMonitors.enabled`       | Enable Sentry ingest monitors                                                                                                                                | `true`                          |
| `sentry.ingestOccurrences.enabled`       | Enable Sentry ingest occurences                                                                                                                                | `true`                          |
| `sentry.ingestReplayRecordings.enabled`       | Enable Sentry ingest replay recordings                                                                                                                                | `true`                          |
| `sentry.metricsConsumer.enabled`       | Enable Sentry metrics consumer                                                                                                                                | `true`                          |
| `sentry.postProcessForwardErrors.enabled`       | Enable Sentry post process forward errors                                                                                                                                | `true`                          |
| `sentry.postProcessForwardIssuePlatform.enabled`       | Enable Sentry post process forward issue platform                                                                                                                                | `true`                          |
| `sentry.postProcessForwardTransactions.enabled`       | Enable Sentry post process forward transactions                                                                                                                                | `true`                          |
| `sentry.subscriptionConsumerEvents.enabled`       | Enable Sentry subscription consumer events                                                                                                                                | `true`                          |
| `sentry.subscriptionConsumerGenericMetrics.enabled`       | Enable Sentry subscription consumer generic metrics                                                                                                                                | `true`                          |
| `sentry.subscriptionConsumerMetrics.enabled`       | Enable Sentry subscription consumer metrics                                                                                                                                | `true`                          |
| `sentry.subscriptionConsumerTransactions.enabled`       | Enable Sentry subscription consumer transactions                                                                                                                                | `true`                          |
| `sentry.sentry.web.enabled`       | Enable Sentry web                                                                                                                                | `true`                          |
| `sentry.sentry.worker.enabled`       | Enable Sentry worker                                                                                                                                | `true`                          |
| `serviceAccount.annotations`                  | Additional Service Account annotations.                                                                                                                             | `{}`                           |
| `serviceAccount.enabled`                      | If `true`, a custom Service Account will be used.                                                                                                                   | `false`                        |
| `serviceAccount.name`                         | The base name of the ServiceAccount to use. Will be appended with e.g. `snuba` or `web` for the pods accordingly.                                                   | `"sentry"`                     |
| `serviceAccount.automountServiceAccountToken` | Automount API credentials for a Service Account.                                                                                                                    | `true`                         |
| `sentry.existingSecret`                       | Existing kubernetes secret to be used for secret key for the session cookie ([documentation](https://develop.sentry.dev/config/#general))                                                                     | `nil`                          |
| `sentry.features.vstsLimitedScopes`           | Disables the azdo-integrations with limited scopes that is the cause of so much pain                                                                                | `true`                         |
| `sentry.web.customCA.secretName`              | Allows mounting a custom CA secret                                                                                                                                  | `nil`                          |
| `sentry.web.customCA.item`                    | Key of CA cert object within the secret                                                                                                                             | `ca.crt`                       |
| `snuba.api.enabled`       | Enable Snuba api                                                                                                                                | `true`                          |
| `snuba.consumer.enabled`       | Enable Snuba consumer                                                                                                                                | `true`                          |
| `snuba.genericMetricsCountersConsumer.enabled`       | Enable Snuba generic metrics counters consumer                                                                                                                                | `true`                          |
| `snuba.genericMetricsDistributionConsumer.enabled`       | Enable Snuba generic metrics distribution consumer                                                                                                                                | `true`                          |
| `snuba.genericMetricsSetsConsumer.enabled`       | Enable Snuba generic metrics sets consumer                                                                                                                                | `true`                          |
| `snuba.issueOccurrenceConsumer.enabled`       | Enable Snuba issue occurrence consumer                                                                                                                                | `true`                          |
| `snuba.metricsConsumer.enabled`       | Enable Snuba metrics consumer                                                                                                                                | `true`                          |
| `snuba.outcomesConsumer.enabled`       | Enable Snuba outcomes consumer                                                                                                                                | `true`                          |
| `snuba.replacer.enabled`       | Enable Snuba replacer                                                                                                                                | `true`                          |
| `snuba.replaysConsumer.enabled`       | Enable Snuba replays consumer                                                                                                                                | `true`                          |
| `snuba.subscriptionConsumerEvents.enabled`       | Enable Snuba subscription consumer events                                                                                                                                | `true`                          |
| `snuba.subscriptionConsumerMetrics.enabled`       | Enable Snuba subscription consumer metrics                                                                                                                                | `true`                          |
| `snuba.subscriptionConsumerTransactions.enabled`       | Enable Snuba subscription consumer transactions                                                                                                                                | `true`                          |
| `snuba.transactionsConsumer.enabled`       | Enable Snuba transactions consumer                                                                                                                                | `true`                          |
| `symbolicator.api.enabled`                    | Enable Symbolicator                                                                                                                                                 | `false`                        |
| `symbolicator.api.config`                     | Config file for Symbolicator, see [its docs](https://getsentry.github.io/symbolicator/#configuration)                                                               | see values.yaml                |

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
  ## List of Hostnames or ip addresses of external kafka
  - host: "233.5.100.28"
    port: 9092
  - host: "233.5.100.29"
    port: 9092
  - host: "233.5.100.30"
    port: 9092
```



# Usage

- [AWS + Terraform](docs/usage-aws-terraform.md)
- [DigitalOcean](docs/usage-digitalocean.md)
