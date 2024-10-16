# Changelog

## [3.13.0](https://github.com/sentry-kubernetes/charts/compare/clickhouse-v3.12.0...clickhouse-v3.13.0) (2024-10-16)


### Features

* **clickhouse:** update ClickHouse version to 23.3.19.32 ([#1552](https://github.com/sentry-kubernetes/charts/issues/1552)) ([05bcae5](https://github.com/sentry-kubernetes/charts/commit/05bcae567473f6d00c92fe3c4da84fc26fc26065))

## [3.12.0](https://github.com/sentry-kubernetes/charts/compare/clickhouse-v3.11.0...clickhouse-v3.12.0) (2024-10-15)


### Features

* **clickhouse:** update ClickHouse version to 22.8.15.23 ([#1550](https://github.com/sentry-kubernetes/charts/issues/1550)) ([4271312](https://github.com/sentry-kubernetes/charts/commit/4271312e55b15f8f91bda7c70e3384042e602f5c))

## [3.11.0](https://github.com/sentry-kubernetes/charts/compare/clickhouse-v3.10.0...clickhouse-v3.11.0) (2024-09-14)


### Features

* update clickhouse chart with new image version and startup probes ([#1429](https://github.com/sentry-kubernetes/charts/issues/1429)) ([efdf1b6](https://github.com/sentry-kubernetes/charts/commit/efdf1b6dcc9215335fe0128b27187aa25bf9256f))

## [3.10.0](https://github.com/sentry-kubernetes/charts/compare/clickhouse-v3.9.0...clickhouse-v3.10.0) (2024-07-11)


### Features

* **clickhouse:** allow overriding Clickhouse host ([#1356](https://github.com/sentry-kubernetes/charts/issues/1356)) ([bf0aaf3](https://github.com/sentry-kubernetes/charts/commit/bf0aaf346d5363fef2b12e2caee6f4b4750d45fd))

## [3.9.0](https://github.com/sentry-kubernetes/charts/compare/clickhouse-v3.8.0...clickhouse-v3.9.0) (2024-05-21)


### Features

* ability to override default clickhouse config ([#1268](https://github.com/sentry-kubernetes/charts/issues/1268)) ([1f8a5d5](https://github.com/sentry-kubernetes/charts/commit/1f8a5d58cedf3f26e759c67d2c5f50ea11d371c1))

## [3.8.0](https://github.com/sentry-kubernetes/charts/compare/clickhouse-v3.7.2...clickhouse-v3.8.0) (2024-04-12)


### Features

* add priorityClassName to clickhouse ([#1098](https://github.com/sentry-kubernetes/charts/issues/1098)) ([386e7b7](https://github.com/sentry-kubernetes/charts/commit/386e7b7328000a289a7642752af583e8f6d40106))
* Allow to set max_suspicious_broken_parts in merge_tree settings… ([#1080](https://github.com/sentry-kubernetes/charts/issues/1080)) ([d2f305c](https://github.com/sentry-kubernetes/charts/commit/d2f305c73b7b0ab625734a30fe5b5363606cd751))
* Allow to set specified merge_tree settings in config.xml ([#884](https://github.com/sentry-kubernetes/charts/issues/884)) ([a964753](https://github.com/sentry-kubernetes/charts/commit/a964753b6fc785292c448e2f8d7c3099c696039d))
* clone clickhouse chart ([#71](https://github.com/sentry-kubernetes/charts/issues/71)) ([d4c252b](https://github.com/sentry-kubernetes/charts/commit/d4c252b752bd637595b2406e88f2118d8609667a))
* distributed tables v2 ([#588](https://github.com/sentry-kubernetes/charts/issues/588)) ([cfe7d73](https://github.com/sentry-kubernetes/charts/commit/cfe7d736278feeeb72189efb841a6099685ed1dd))
* put clickhouse with UTC timezone per default ([#82](https://github.com/sentry-kubernetes/charts/issues/82)) ([daab634](https://github.com/sentry-kubernetes/charts/commit/daab634449ce10ad45a0f73c765e04033a8cb657))
* **tabix:** allow setting ingress annotations for dealing with cors ([#321](https://github.com/sentry-kubernetes/charts/issues/321)) ([b11361f](https://github.com/sentry-kubernetes/charts/commit/b11361f2fe6b27504d2f0fda4a12bc5ade780b05))


### Bug Fixes

* clickhouse chart lint ([a364b05](https://github.com/sentry-kubernetes/charts/commit/a364b053069ab9330af6c8bfd0d2bda619ada0f0))
* clickhouse ingress ([#99](https://github.com/sentry-kubernetes/charts/issues/99)) ([94da94d](https://github.com/sentry-kubernetes/charts/commit/94da94d15a9528ebdb4782c20af48b02e0a256bf))
* make ingress, rbac compatible with latest k8s versions ([#114](https://github.com/sentry-kubernetes/charts/issues/114)) ([8d2f319](https://github.com/sentry-kubernetes/charts/commit/8d2f3196fe797a301ba6ebb21b793f3030d70962))
* replace hardcoded value ([#1085](https://github.com/sentry-kubernetes/charts/issues/1085)) ([c5fec72](https://github.com/sentry-kubernetes/charts/commit/c5fec72ad8dc16e727019094d07dbaae4359cdf8))

## 3.7.2 (2024-04-12)


### Features

* add priorityClassName to clickhouse ([#1098](https://github.com/sentry-kubernetes/charts/issues/1098)) ([386e7b7](https://github.com/sentry-kubernetes/charts/commit/386e7b7328000a289a7642752af583e8f6d40106))
* Allow to set max_suspicious_broken_parts in merge_tree settings… ([#1080](https://github.com/sentry-kubernetes/charts/issues/1080)) ([d2f305c](https://github.com/sentry-kubernetes/charts/commit/d2f305c73b7b0ab625734a30fe5b5363606cd751))
* Allow to set specified merge_tree settings in config.xml ([#884](https://github.com/sentry-kubernetes/charts/issues/884)) ([a964753](https://github.com/sentry-kubernetes/charts/commit/a964753b6fc785292c448e2f8d7c3099c696039d))
* clone clickhouse chart ([#71](https://github.com/sentry-kubernetes/charts/issues/71)) ([d4c252b](https://github.com/sentry-kubernetes/charts/commit/d4c252b752bd637595b2406e88f2118d8609667a))
* distributed tables v2 ([#588](https://github.com/sentry-kubernetes/charts/issues/588)) ([cfe7d73](https://github.com/sentry-kubernetes/charts/commit/cfe7d736278feeeb72189efb841a6099685ed1dd))
* put clickhouse with UTC timezone per default ([#82](https://github.com/sentry-kubernetes/charts/issues/82)) ([daab634](https://github.com/sentry-kubernetes/charts/commit/daab634449ce10ad45a0f73c765e04033a8cb657))
* **tabix:** allow setting ingress annotations for dealing with cors ([#321](https://github.com/sentry-kubernetes/charts/issues/321)) ([b11361f](https://github.com/sentry-kubernetes/charts/commit/b11361f2fe6b27504d2f0fda4a12bc5ade780b05))


### Bug Fixes

* clickhouse chart lint ([a364b05](https://github.com/sentry-kubernetes/charts/commit/a364b053069ab9330af6c8bfd0d2bda619ada0f0))
* clickhouse ingress ([#99](https://github.com/sentry-kubernetes/charts/issues/99)) ([94da94d](https://github.com/sentry-kubernetes/charts/commit/94da94d15a9528ebdb4782c20af48b02e0a256bf))
* make ingress, rbac compatible with latest k8s versions ([#114](https://github.com/sentry-kubernetes/charts/issues/114)) ([8d2f319](https://github.com/sentry-kubernetes/charts/commit/8d2f3196fe797a301ba6ebb21b793f3030d70962))
* replace hardcoded value ([#1085](https://github.com/sentry-kubernetes/charts/issues/1085)) ([c5fec72](https://github.com/sentry-kubernetes/charts/commit/c5fec72ad8dc16e727019094d07dbaae4359cdf8))
