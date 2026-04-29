# Sentry helm charts

Sentry is a cross-platform crash reporting and aggregation platform.

This repository aims to support Sentry >=10 and move out from the deprecated Helm charts official repo.

Big thanks to the maintainers of the [deprecated chart](https://github.com/helm/charts/tree/master/stable/sentry). This work has been partly inspired by it.

## How this chart works

```
helm repo add sentry https://sentry-kubernetes.github.io/charts
helm repo update
helm install my-sentry sentry/sentry --wait --timeout=1000s
```

## Values

Each chart has its own `README.md` in its directory with values and configuration instructions (for example `charts/sentry/README.md`).
See [CHANGELOG](CHANGELOG.md) for upgrade instructions and version history.

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
