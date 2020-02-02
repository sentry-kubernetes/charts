# Sentry 10 helm charts

Sentry is a cross-platform crash reporting and aggregation platform.

This repository aims to support Sentry 10 and move out from the deprecated Helm charts official repo.

Big thanks from the maintainers of the [deprecated chart](https://github.com/helm/charts/tree/master/stable/sentry). This work has been partly inspired by it.

## How this chart works

This repository contains 2 charts : 
- sentry, containing all the sentry services
- sentry-db, containing all the (optional) databases

`helm repo add sentry https://sentry-kubernetes.github.io/charts/charts`

## Values

For now the full list of values is not documented but you can get inspired by the values.yaml specific to each directory.

## Roadmap

- [X] Lint in Pull requests
- [X] Public availability through Github Pages
- [X] Automatic deployment through Github Actions
- [ ] Symbolicator deployment
- [ ] Testing the chart in a production environment
- [ ] Improving the README
