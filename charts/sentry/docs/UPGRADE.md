# Upgrade

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

## Upgrading from 11.x.x version of this Chart to 12.0.0

Redis chart was upgraded to newer version. If you are using external redis, you don't need to do anything.

Otherwise, when upgrading to chart version 12.x.x from 11.x.x you need to either run `helm upgrade` with `--force` flag, or prior to upgrade delete statefulsets for redis master and redis slave. Then run upgrade and it will roll out new statefulsets. Your master redis data will not be lost (PVC is not deleted when you delete statefulset). Your redis slave will now be named redis replica and you can delete PVCs that were used by redis slave after the upgrade.

## Upgrading from 10.x.x version of this Chart to 11.0.0

If you were using clickhouse tabix externally, we disabled it per default.

## Upgrading from deprecated 9.0 -> 10.0 Chart

As this chart runs in helm 3 and also tries its best to follow on from the original Sentry chart. There are some steps that needs to be taken in order to correctly upgrade.

From the previous upgrade, make sure to get the following from your previous installation:

- Redis Password (If Redis auth was enabled)
- Postgresql Password
  Both should be in the `secrets` of your original 9.0 release. Make a note of both of these values.

### Upgrade Steps

Due to an issue where transferring from Helm 2 to 3. Statefulsets that use the following: `heritage: {{ .Release.Service }}` in the metadata field will error out with a `Forbidden` error during the upgrade. The only workaround is to delete the existing statefulsets (Don't worry, PVC will be retained):

```shell
kubectl delete --all sts -n <Sentry Namespace>
```

Once the statefulsets are deleted. Next steps is to convert the helm release from version 2 to 3 using the helm 3 plugin:

```shell
helm3 2to3 convert <Sentry Release Name>
```

Finally, it's just a case of upgrading and ensuring the correct params are used:

If Redis auth enabled:

```shell
helm upgrade -n <Sentry namespace> <Sentry Release> . --set redis.usePassword=true --set redis.password=<Redis Password>
```

If Redis auth is disabled:

```shell
helm upgrade -n <Sentry namespace> <Sentry Release> .
```
