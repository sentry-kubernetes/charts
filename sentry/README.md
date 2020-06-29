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
