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

## PostgresSQL

By default, PostgreSQL is installed as part of the chart. To use an external PostgreSQL server set `postgresql.enabled` to `false` and then set `postgresql.postgresHost` and `postgresql.postgresqlPassword`. The other options (`postgresql.postgresqlDatabase`, `postgresql.postgresqlUsername` and `postgresql.postgresqlPort`) may also want changing from their default values.

To avoid issues when upgrade this chart, provide `postgresql.postgresqlPassword` for subsequent upgrades. This is due to an issue in the PostgreSQL chart where password will be overwritten with randomly generated passwords otherwise. See https://github.com/helm/charts/tree/master/stable/postgresql#upgrade for more detail.

## Roadmap

- [X] Lint in Pull requests
- [X] Public availability through Github Pages
- [X] Automatic deployment through Github Actions
- [ ] Symbolicator deployment
- [ ] Testing the chart in a production environment
- [ ] Improving the README
