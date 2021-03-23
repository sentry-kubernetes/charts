### Upgrading from deprecated 9.0 -> 10.0 Chart

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

> helm upgrade -n <Sentry namespace> <Sentry Release> . --set redis.usePassword=true --set redis.password=<Redis Password>

If Redis auth is disabled:
> helm upgrade -n <Sentry namespace> <Sentry Release> .

## Configuration

The following table lists the configurable parameters of the Sentry chart and their default values.

Note: this table is incomplete, so have a look at the values.yaml in case you miss something

Parameter                          | Description                                                                                                | Default
:--------------------------------- | :--------------------------------------------------------------------------------------------------------- | :---------------------------------------------------
`user.create` | if `true`, creates a default admin user defined from `email` and `password` | `true`
`user.email` | Admin user email | `admin@sentry.local`
`user.password` | Admin user password| `aaaa`
`ingress.enabled` | Enabling Ingress | `false`
`ingress.regexPathStyle` | Allows setting the style the regex paths are rendered in the ingress for the ingress controller in use. Possible values are `nginx`, `aws-alb` and `traefik` | `nginx`
`nginx.enabled` | Enabling NGINX | `true`
`metrics.enabled`| if `true`, enable Prometheus metrics | `false`
`metrics.image.repository`         | Metrics exporter image repository                                                                          | `prom/statsd-exporter`
`metrics.image.tag`                | Metrics exporter image tag                                                                                 | `v0.10.5`
`metrics.image.PullPolicy`         | Metrics exporter image pull policy                                                                         | `IfNotPresent`
`metrics.nodeSelector`| Node labels for metrics pod assignment| `{}`
`metrics.tolerations` | Toleration labels for metrics pod assignment| `[]`
`metrics.affinity` | Affinity settings for metrics | `{}`
`metrics.resources`| Metrics resource requests/limit| `{}`
`metrics.service.annotations` | annotations for Prometheus metrics service | `{}`
`metrics.service.clusterIP` | cluster IP address to assign to service (set to `"-"` to pass an empty value) | `nil`
`metrics.service.omitClusterIP` | (Deprecated) To omit the `clusterIP` from the metrics service | `false`
`metrics.service.externalIPs` | Prometheus metrics service external IP addresses | `[]`
`metrics.service.additionalLabels` | labels for metrics service | `{}`
`metrics.service.loadBalancerIP` | IP address to assign to load balancer (if supported) | `""`
`metrics.service.loadBalancerSourceRanges` | list of IP CIDRs allowed access to load balancer (if supported) | `[]`
`metrics.service.servicePort` | Prometheus metrics service port | `9913`
`metrics.service.type` | type of Prometheus metrics service to create | `ClusterIP`
`metrics.serviceMonitor.enabled` | Set this to `true` to create ServiceMonitor for Prometheus operator | `false`
`metrics.serviceMonitor.additionalLabels` | Additional labels that can be used so ServiceMonitor will be discovered by Prometheus | `{}`
`metrics.serviceMonitor.honorLabels` | honorLabels chooses the metric's labels on collisions with target labels. | `false`
`metrics.serviceMonitor.namespace` | namespace where servicemonitor resource should be created | `the same namespace as sentry`
`metrics.serviceMonitor.scrapeInterval` | interval between Prometheus scraping | `30s`
`system.secretKey` | secret key for the session cookie ([documentation](https://develop.sentry.dev/config/#general)) | `nil`
`sentry.features.vstsLimitedScopes` | Disables the azdo-integrations with limited scopes that is the cause of so much pain | `true`
`sentry.web.customCA.secretName` | Allows mounting a custom CA secret | `nil`
`sentry.web.customCA.item` | Key of CA cert object within the secret | `ca.crt`
`symbolicator.api.enabled` | Enable Symbolicator | `false`
`symbolicator.api.config` | Config file for Symbolicator, see [its docs](https://getsentry.github.io/symbolicator/#configuration) | see values.yaml

## NGINX and/or Ingress

By default, NGINX is enabled to allow sending the incoming requests to [Sentry Relay](https://getsentry.github.io/relay/) or the Django backend depending on the path. When Sentry is meant to be exposed outside of the Kubernetes cluster, it is recommended to disable NGINX and let the Ingress do the same. It's recommended to go with the go to Ingress Controller, [NGINX Ingress](https://kubernetes.github.io/ingress-nginx/) but others should work as well.

## Sentry secret key

For your security, the [`system.secret-key`](https://develop.sentry.dev/config/#general) is generated for you on the first installation. Another one will be regenerated on each upgrade invalidating all the current sessions unless it's been provided. The value is stored in the `sentry-sentry` configmap.

```
helm upgrade ... --set system.secretKey=xx
```

## Symbolicator

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

