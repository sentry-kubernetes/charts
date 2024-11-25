# Changelog

## [26.6.0](https://github.com/sentry-kubernetes/charts/compare/sentry-v26.5.0...sentry-v26.6.0) (2024-11-25)


### Features

* disable Sentry anonymous usage statistics ([#1608](https://github.com/sentry-kubernetes/charts/issues/1608)) ([b679d97](https://github.com/sentry-kubernetes/charts/commit/b679d97e21e787857a7d1dc8fd7c84ceb759e083))

## [26.5.0](https://github.com/sentry-kubernetes/charts/compare/sentry-v26.4.0...sentry-v26.5.0) (2024-11-05)


### Features

* recovery support multi hosts and ports of external kafka cluster ([#1588](https://github.com/sentry-kubernetes/charts/issues/1588)) ([889bd0d](https://github.com/sentry-kubernetes/charts/commit/889bd0d47235cb1ab5a7b52439f5b8df61026a03))

## [26.4.0](https://github.com/sentry-kubernetes/charts/compare/sentry-v26.3.0...sentry-v26.4.0) (2024-11-03)


### Features

* add maxBatchTimeMs, maxPollIntervalMs for ingestConsumerAttachments ([#1591](https://github.com/sentry-kubernetes/charts/issues/1591)) ([72af218](https://github.com/sentry-kubernetes/charts/commit/72af2189d2249cc29de1442179ce2258da958e44))

## [26.3.0](https://github.com/sentry-kubernetes/charts/compare/sentry-v26.2.0...sentry-v26.3.0) (2024-10-26)


### Features

* Introduce global tolerations across all components ([#1580](https://github.com/sentry-kubernetes/charts/issues/1580)) ([7b48399](https://github.com/sentry-kubernetes/charts/commit/7b48399efe73cbb582b4df34068d0104ae3d969c))

## [26.2.0](https://github.com/sentry-kubernetes/charts/compare/sentry-v26.1.0...sentry-v26.2.0) (2024-10-25)


### Features

* allow users to specify Kafka topic name prefix in values.yaml ([#1544](https://github.com/sentry-kubernetes/charts/issues/1544)) ([5693406](https://github.com/sentry-kubernetes/charts/commit/569340626ce1587d48040a939b80ab74874fd022))
* **rabbitmq:** updated configuration to support Prometheus ([#1578](https://github.com/sentry-kubernetes/charts/issues/1578)) ([35f779a](https://github.com/sentry-kubernetes/charts/commit/35f779a0f18b2b9108470efc86403fa3c0eefae2))

## [26.1.0](https://github.com/sentry-kubernetes/charts/compare/sentry-v26.0.0...sentry-v26.1.0) (2024-10-25)


### Features

* add global nodeSelector fallback for all deployments ([#1576](https://github.com/sentry-kubernetes/charts/issues/1576)) ([d6eec42](https://github.com/sentry-kubernetes/charts/commit/d6eec42b2c31f42a473d1241721ff3d64111400f))

## [26.0.0](https://github.com/sentry-kubernetes/charts/compare/sentry-v25.20.0...sentry-v26.0.0) (2024-10-24)


### ⚠ BREAKING CHANGES

Make sure to upgrade to chart version 25.20.0 (Seentry 24.8.0) before upgrading to 26.x.x

**Note:** In version [sentry-v25.19.0](https://github.com/sentry-kubernetes/charts/releases/tag/sentry-v26.5.0) ([commit](https://github.com/sentry-kubernetes/charts/commit/f5a12e04ee5ffa28f1d62bf6c7cb5c733b30c2b9)), SASL authentication functionality for Kafka was added, which broke backward compatibility when using an external Kafka cluster. The single-host external kafka setup works correctly. The [issue #1584](https://github.com/sentry-kubernetes/charts/issues/1584) was fixed in version [sentry-v26.5.0](https://github.com/sentry-kubernetes/charts/releases/tag/sentry-v26.5.0) ([commit](https://github.com/sentry-kubernetes/charts/commit/889bd0d47235cb1ab5a7b52439f5b8df61026a03)). In this case, for a sequential upgrade, a viable workaround could be to use [sentry-v26.5.0](https://github.com/sentry-kubernetes/charts/releases/tag/sentry-v26.5.0) with `appVersion: 24.8.0` initially ([Chart.yml](https://github.com/sentry-kubernetes/charts/blob/sentry-v26.5.0/charts/sentry/Chart.yaml#L6)), and then use [sentry-v26.5.0](https://github.com/sentry-kubernetes/charts/releases/tag/sentry-v26.5.0) as is ([details](https://github.com/sentry-kubernetes/charts/pull/1588#issuecomment-2459117235)).

### Features

* add maxTasksPerChild option to Sentry worker deployments ([#1572](https://github.com/sentry-kubernetes/charts/issues/1572)) ([bc32900](https://github.com/sentry-kubernetes/charts/commit/bc329004f46f4af7ecf4a99f07e74e28dbee436e))
* update sentry appVersion to 24.9.0 ([#1571](https://github.com/sentry-kubernetes/charts/issues/1571)) ([2a3a030](https://github.com/sentry-kubernetes/charts/commit/2a3a030ba3c61c6792712c4f637fe64d42a47fe2))

## [25.20.0](https://github.com/sentry-kubernetes/charts/compare/sentry-v25.19.0...sentry-v25.20.0) (2024-10-23)


### Features

* update sentry appVersion to 24.8.0 ([#1569](https://github.com/sentry-kubernetes/charts/issues/1569)) ([cb731e0](https://github.com/sentry-kubernetes/charts/commit/cb731e0cba028907fff29ed9e1525e544694ec32))

## [25.19.0](https://github.com/sentry-kubernetes/charts/compare/sentry-v25.18.0...sentry-v25.19.0) (2024-10-22)


### Features

* **clickhouse:** remove explicit imageVersion, inherit from chart ([#1561](https://github.com/sentry-kubernetes/charts/issues/1561)) ([4d003fd](https://github.com/sentry-kubernetes/charts/commit/4d003fdc350f1427d413285b94bf27fd13635239))
* **sentry:** add sasl auth for kafka and manage settings of connections ([#1557](https://github.com/sentry-kubernetes/charts/issues/1557)) ([f5a12e0](https://github.com/sentry-kubernetes/charts/commit/f5a12e04ee5ffa28f1d62bf6c7cb5c733b30c2b9))


### Bug Fixes

* **snuba:** Add missing --no-strict-offset-reset for replacer ([#1559](https://github.com/sentry-kubernetes/charts/issues/1559)) ([0c415e7](https://github.com/sentry-kubernetes/charts/commit/0c415e704fb2f2cbb984d3e0d5e3b08895834436))
* Use correct syntax for envFrom in web and worker ([#1563](https://github.com/sentry-kubernetes/charts/issues/1563)) ([b834c0e](https://github.com/sentry-kubernetes/charts/commit/b834c0e4651633ca88e4c1839d60c0c69cf52087))

## [25.18.0](https://github.com/sentry-kubernetes/charts/compare/sentry-v25.17.1...sentry-v25.18.0) (2024-10-16)


### Features

* **clickhouse:** update ClickHouse chart to 3.12.0 ([#1556](https://github.com/sentry-kubernetes/charts/issues/1556)) ([07e73c1](https://github.com/sentry-kubernetes/charts/commit/07e73c1846c242f1babaa1ed47271588c9ec2daf))

## [25.17.1](https://github.com/sentry-kubernetes/charts/compare/sentry-v25.17.0...sentry-v25.17.1) (2024-10-15)


### Bug Fixes

* external redis functionality for relay ([#1548](https://github.com/sentry-kubernetes/charts/issues/1548)) ([6e71fc1](https://github.com/sentry-kubernetes/charts/commit/6e71fc169622c2e7e4934bfefd613f613a6c77d2))

## [25.17.0](https://github.com/sentry-kubernetes/charts/compare/sentry-v25.16.0...sentry-v25.17.0) (2024-10-14)


### Features

* add logLevel and logFormat options for worker events and transactions ([#1542](https://github.com/sentry-kubernetes/charts/issues/1542)) ([bfbdd4d](https://github.com/sentry-kubernetes/charts/commit/bfbdd4d95bf15b18a72ed3d5af2baa363e98d6b6))

## [25.16.0](https://github.com/sentry-kubernetes/charts/compare/sentry-v25.15.1...sentry-v25.16.0) (2024-10-14)


### Features

* **snuba:** add events_analytics_platform to settings ([#1540](https://github.com/sentry-kubernetes/charts/issues/1540)) ([b035b10](https://github.com/sentry-kubernetes/charts/commit/b035b10fb96d7081abcab8cf03a5f63e814a4871))

## [25.15.1](https://github.com/sentry-kubernetes/charts/compare/sentry-v25.15.0...sentry-v25.15.1) (2024-10-14)


### Bug Fixes

* conditionally set auto-offset-reset for snuba subscription consumers ([#1538](https://github.com/sentry-kubernetes/charts/issues/1538)) ([db26b85](https://github.com/sentry-kubernetes/charts/commit/db26b853246e8f213d25f8c5041893e54a556630))

## [25.15.0](https://github.com/sentry-kubernetes/charts/compare/sentry-v25.14.0...sentry-v25.15.0) (2024-10-13)


### Features

* **sentry:** Add missing --no-strict-offset-reset and --auto-offset-reset for consumers ([#1535](https://github.com/sentry-kubernetes/charts/issues/1535)) ([8e0eea0](https://github.com/sentry-kubernetes/charts/commit/8e0eea0e5a3805c93d19ea93240d634953461cea))

## [25.14.0](https://github.com/sentry-kubernetes/charts/compare/sentry-v25.13.4...sentry-v25.14.0) (2024-10-13)


### Features

* offset-reset in ds ([#1533](https://github.com/sentry-kubernetes/charts/issues/1533)) ([0e3ef2d](https://github.com/sentry-kubernetes/charts/commit/0e3ef2db47c552fc80d07442263764a33c11c0d3))

## [25.13.4](https://github.com/sentry-kubernetes/charts/compare/sentry-v25.13.3...sentry-v25.13.4) (2024-10-13)


### Bug Fixes

* symbolicator storage class ([#1530](https://github.com/sentry-kubernetes/charts/issues/1530)) ([26cbaab](https://github.com/sentry-kubernetes/charts/commit/26cbaab28dcb0c95ac10723ed62b453c678b9787))

## [25.13.3](https://github.com/sentry-kubernetes/charts/compare/sentry-v25.13.2...sentry-v25.13.3) (2024-10-12)


### Bug Fixes

* update geoip job hooks and volume handling ([#1529](https://github.com/sentry-kubernetes/charts/issues/1529)) ([886eb5f](https://github.com/sentry-kubernetes/charts/commit/886eb5fe8110bfb1a973740ca3a1a2e3e776c003))

## [25.13.2](https://github.com/sentry-kubernetes/charts/compare/sentry-v25.13.1...sentry-v25.13.2) (2024-10-08)


### Bug Fixes

* correct storageClass handling for geodata persistence ([#1524](https://github.com/sentry-kubernetes/charts/issues/1524)) ([b2f568d](https://github.com/sentry-kubernetes/charts/commit/b2f568d926771208256d47f03a2f39806ca94fe3))

## [25.13.1](https://github.com/sentry-kubernetes/charts/compare/sentry-v25.13.0...sentry-v25.13.1) (2024-10-08)


### Bug Fixes

* correct argument order of consumers ([#1522](https://github.com/sentry-kubernetes/charts/issues/1522)) ([6236a74](https://github.com/sentry-kubernetes/charts/commit/6236a74e70a78525a6030ade5cd3fc29b424fe59))

## [25.13.0](https://github.com/sentry-kubernetes/charts/compare/sentry-v25.12.0...sentry-v25.13.0) (2024-10-07)


### Features

* add geoip support to sentry deployment ([#1516](https://github.com/sentry-kubernetes/charts/issues/1516)) ([4f2429b](https://github.com/sentry-kubernetes/charts/commit/4f2429b746fe13002c21abf233338a293acff1a0))

## [25.12.0](https://github.com/sentry-kubernetes/charts/compare/sentry-v25.11.1...sentry-v25.12.0) (2024-10-07)


### Features

* add existingSecretEnv support for web and worker deployments ([#1509](https://github.com/sentry-kubernetes/charts/issues/1509)) ([b170ac3](https://github.com/sentry-kubernetes/charts/commit/b170ac33a64e41a36bfeb416e05801ec9ae1365d))
* allow customization of kafka configuration ([#1514](https://github.com/sentry-kubernetes/charts/issues/1514)) ([5f4009b](https://github.com/sentry-kubernetes/charts/commit/5f4009b97898bea66749436b792e4a9815df4be8))


### Bug Fixes

* user-create-job hook does not create user ([5f4009b](https://github.com/sentry-kubernetes/charts/commit/5f4009b97898bea66749436b792e4a9815df4be8))

## [25.11.1](https://github.com/sentry-kubernetes/charts/compare/sentry-v25.11.0...sentry-v25.11.1) (2024-10-01)


### Bug Fixes

* reintroduced "Extend Redis functionality" ([#1492](https://github.com/sentry-kubernetes/charts/issues/1492)) broke S3 existing secret (from commit 0b7a7b4c) ([#1499](https://github.com/sentry-kubernetes/charts/issues/1499)) ([3eb75ef](https://github.com/sentry-kubernetes/charts/commit/3eb75ef861c68279975d2baa846bdf9b678474f3))

## [25.11.0](https://github.com/sentry-kubernetes/charts/compare/sentry-v25.10.1...sentry-v25.11.0) (2024-09-30)


### Features

* reintroduce "Extend Redis functionality" ([#1492](https://github.com/sentry-kubernetes/charts/issues/1492)) ([0b7a7b4](https://github.com/sentry-kubernetes/charts/commit/0b7a7b4c874bf4d4a460c88bb259cab0e025f7ee))

## [25.10.1](https://github.com/sentry-kubernetes/charts/compare/sentry-v25.10.0...sentry-v25.10.1) (2024-09-30)


### Bug Fixes

* add topic partition counts in snuba config for correct ([#1489](https://github.com/sentry-kubernetes/charts/issues/1489)) ([2b44fb2](https://github.com/sentry-kubernetes/charts/commit/2b44fb2a449410a64aa4628e06fdd4e1cb1ae6aa))
* configuring kafka to use zookeeper uses only brokers, and service name in db-check is wrong ([#1494](https://github.com/sentry-kubernetes/charts/issues/1494)) ([34d4975](https://github.com/sentry-kubernetes/charts/commit/34d49752a9869372a69ce6add1011be1155ec254))

## [25.10.0](https://github.com/sentry-kubernetes/charts/compare/sentry-v25.9.0...sentry-v25.10.0) (2024-09-25)


### Features

* update kafka for fix jmx-exporter scrape path ([#1477](https://github.com/sentry-kubernetes/charts/issues/1477)) ([a1c6250](https://github.com/sentry-kubernetes/charts/commit/a1c6250f70245f6514ddbe8e15741250bd6de1a2))

## [25.9.0](https://github.com/sentry-kubernetes/charts/compare/sentry-v25.8.1...sentry-v25.9.0) (2024-09-18)


### Features

* add logLevel option to ingestConsumerAttachments ([#1468](https://github.com/sentry-kubernetes/charts/issues/1468)) ([8005f0f](https://github.com/sentry-kubernetes/charts/commit/8005f0fcebf9856a3a29a99f596452a2c481a58c))

## [25.8.1](https://github.com/sentry-kubernetes/charts/compare/sentry-v25.8.0...sentry-v25.8.1) (2024-09-17)


### Bug Fixes

* correct nginx.conf and ingress settings for sentry 24.7.1 and ([#1466](https://github.com/sentry-kubernetes/charts/issues/1466)) ([cfb90ef](https://github.com/sentry-kubernetes/charts/commit/cfb90efd05b7b1b03cf191df4324e2092f50e4dc))
* correct order of arguments of sentry consumers ([#1463](https://github.com/sentry-kubernetes/charts/issues/1463)) ([#1464](https://github.com/sentry-kubernetes/charts/issues/1464)) ([2861efa](https://github.com/sentry-kubernetes/charts/commit/2861efa7192b8d8bc02835ef4ade16a21b2729f1))

## [25.8.0](https://github.com/sentry-kubernetes/charts/compare/sentry-v25.7.0...sentry-v25.8.0) (2024-09-16)


### Features

* add logging and worker settings to Sentry web deployment ([#1459](https://github.com/sentry-kubernetes/charts/issues/1459)) ([f0427e2](https://github.com/sentry-kubernetes/charts/commit/f0427e219773382eee4580bc4170d221f5150eee))

## [25.7.0](https://github.com/sentry-kubernetes/charts/compare/sentry-v25.6.0...sentry-v25.7.0) (2024-09-14)


### Features

* **symbolicator:** implement deployment and statefulset selection ([#1453](https://github.com/sentry-kubernetes/charts/issues/1453)) ([112c1b5](https://github.com/sentry-kubernetes/charts/commit/112c1b50456273163f6692d16787c4d04fe87cda))

## [25.6.0](https://github.com/sentry-kubernetes/charts/compare/sentry-v25.5.1...sentry-v25.6.0) (2024-09-14)


### Features

* updated sentry to 24.7.1 ([#1454](https://github.com/sentry-kubernetes/charts/issues/1454)) ([7874e56](https://github.com/sentry-kubernetes/charts/commit/7874e569217e8469c5ce40087ecd656309a01bba))

## [25.5.1](https://github.com/sentry-kubernetes/charts/compare/sentry-v25.5.0...sentry-v25.5.1) (2024-09-12)


### Bug Fixes

* correct podLabels type from list to map in values.yaml ([#1448](https://github.com/sentry-kubernetes/charts/issues/1448)) ([0c34ecc](https://github.com/sentry-kubernetes/charts/commit/0c34ecca3874c4ff1162c76457993bbe29238b96))
* invalid parameter in deployments ([#1446](https://github.com/sentry-kubernetes/charts/issues/1446)) ([dbafa66](https://github.com/sentry-kubernetes/charts/commit/dbafa66025fd9ecb3eb4b07a5df53f97221e77da))

## [25.5.0](https://github.com/sentry-kubernetes/charts/compare/sentry-v25.4.0...sentry-v25.5.0) (2024-09-11)


### Features

* enhance nginx config to handle disabled sentry relay ([#1430](https://github.com/sentry-kubernetes/charts/issues/1430)) ([4395dba](https://github.com/sentry-kubernetes/charts/commit/4395dba949ca41375bcf0c24435344406cc2bbb7))

## [25.4.0](https://github.com/sentry-kubernetes/charts/compare/sentry-v25.3.0...sentry-v25.4.0) (2024-09-10)


### Features

* add cache, logging, and kafka configuration options to sentry relay ([#1438](https://github.com/sentry-kubernetes/charts/issues/1438)) ([4a84c9f](https://github.com/sentry-kubernetes/charts/commit/4a84c9f5168969e044c0303ca81b60ce743303fd))
* add excludequeues option to sentry worker deployment ([#1441](https://github.com/sentry-kubernetes/charts/issues/1441)) ([78e80fb](https://github.com/sentry-kubernetes/charts/commit/78e80fb35677b1174e9d6d5dcbc37f58a32b86ac))

## [25.3.0](https://github.com/sentry-kubernetes/charts/compare/sentry-v25.2.2...sentry-v25.3.0) (2024-09-05)


### Features

* enhance logging options and add missing configuration parameters ([#1419](https://github.com/sentry-kubernetes/charts/issues/1419)) ([c666226](https://github.com/sentry-kubernetes/charts/commit/c666226346114998ff3c04a005d494e79bd7e13e))

## [25.2.2](https://github.com/sentry-kubernetes/charts/compare/sentry-v25.2.1...sentry-v25.2.2) (2024-09-04)


### Bug Fixes

* remove invalid --max-batch-size and --processes parameters from some consumers ([#1416](https://github.com/sentry-kubernetes/charts/issues/1416)) ([e42dc12](https://github.com/sentry-kubernetes/charts/commit/e42dc12e9bddee1e4d42db7173901ccde0cd3371))

## [25.2.1](https://github.com/sentry-kubernetes/charts/compare/sentry-v25.2.0...sentry-v25.2.1) (2024-09-03)


### Bug Fixes

* del --max-batch-time-ms and enable maxBatchTimeMs in values ([#1412](https://github.com/sentry-kubernetes/charts/issues/1412)) ([086b477](https://github.com/sentry-kubernetes/charts/commit/086b47720b8fe0ee15fd65eafc5446dccc903366))
* discord template typos ([#1408](https://github.com/sentry-kubernetes/charts/issues/1408)) ([044cc25](https://github.com/sentry-kubernetes/charts/commit/044cc254873911ae668e1c6bd1a34ac0883a1db8))

## [25.2.0](https://github.com/sentry-kubernetes/charts/compare/sentry-v25.1.0...sentry-v25.2.0) (2024-09-02)


### Features

* add logLevel, maxPollIntervalMs, inputBlockSize, maxBatchTimeMs ([#1403](https://github.com/sentry-kubernetes/charts/issues/1403)) ([78de49b](https://github.com/sentry-kubernetes/charts/commit/78de49b0f94633cf098aff320a79d7a48443b9a5))

## [25.1.0](https://github.com/sentry-kubernetes/charts/compare/sentry-v25.0.1...sentry-v25.1.0) (2024-08-26)


### Features

* add noStrictOffsetReset for ingest-consumer-attachments ([#1398](https://github.com/sentry-kubernetes/charts/issues/1398)) ([599294c](https://github.com/sentry-kubernetes/charts/commit/599294c33b9e5dfd076e581386a614f60fca38ef))

## [25.0.1](https://github.com/sentry-kubernetes/charts/compare/sentry-v25.0.0...sentry-v25.0.1) (2024-08-23)


### Bug Fixes

* clickhouse replicas 1 ([d789562](https://github.com/sentry-kubernetes/charts/commit/d789562cbde4371b0057272976a981f66229ca50))

## [25.0.0](https://github.com/sentry-kubernetes/charts/compare/sentry-v24.0.1...sentry-v25.0.0) (2024-08-23)


### ⚠ BREAKING CHANGES

* change default values again

### Bug Fixes

* change default values again ([a282b7e](https://github.com/sentry-kubernetes/charts/commit/a282b7e718c37c7d5d25aef19b6372ae00180ab0))

## [24.0.1](https://github.com/sentry-kubernetes/charts/compare/sentry-v24.0.0...sentry-v24.0.1) (2024-08-22)


### Bug Fixes

* revert ClickHouse replicas number ([#1392](https://github.com/sentry-kubernetes/charts/issues/1392)) ([ad6fc29](https://github.com/sentry-kubernetes/charts/commit/ad6fc293e627f78f15b960b8d8cbc0d606cd194f))

## [24.0.0](https://github.com/sentry-kubernetes/charts/compare/sentry-v23.12.1...sentry-v24.0.0) (2024-08-19)


### ⚠ BREAKING CHANGES

* deployment default values ([#1379](https://github.com/sentry-kubernetes/charts/issues/1379))

### Features

* add optional relabeling configs to serviceMonitor object ([#1390](https://github.com/sentry-kubernetes/charts/issues/1390)) ([4f6e440](https://github.com/sentry-kubernetes/charts/commit/4f6e440c5c69ab728a2e9ac9a56b55ce274c5dc1))


### Bug Fixes

* deployment default values ([#1379](https://github.com/sentry-kubernetes/charts/issues/1379)) ([72376fd](https://github.com/sentry-kubernetes/charts/commit/72376fd0aeb9d7fdb6b30a275ae59429bb88da12))

## [23.12.1](https://github.com/sentry-kubernetes/charts/compare/sentry-v23.12.0...sentry-v23.12.1) (2024-07-19)


### Bug Fixes

* update memcached chart to 7.4.8 ([#1352](https://github.com/sentry-kubernetes/charts/issues/1352)) ([a39ae5b](https://github.com/sentry-kubernetes/charts/commit/a39ae5b5252b0535f76ee1dbaccf723dbc1bd6fb))

## [23.12.0](https://github.com/sentry-kubernetes/charts/compare/sentry-v23.11.0...sentry-v23.12.0) (2024-07-11)


### Features

* add parameters for web workers TTL ([#1355](https://github.com/sentry-kubernetes/charts/issues/1355)) ([a1b218f](https://github.com/sentry-kubernetes/charts/commit/a1b218f69a8ea20a987e11a94dbf052d5a05d3a8))


### Bug Fixes

* remove 'profiling-global-suspect-functions' as it is not supported on self hosted ([#1358](https://github.com/sentry-kubernetes/charts/issues/1358)) ([25004f6](https://github.com/sentry-kubernetes/charts/commit/25004f67e4cba551bb78d5c42af80d2e631c50de))

## [23.11.0](https://github.com/sentry-kubernetes/charts/compare/sentry-v23.10.0...sentry-v23.11.0) (2024-06-24)


### Features

* add multiprocess to postProcessForwardTransactions ([#1334](https://github.com/sentry-kubernetes/charts/issues/1334)) ([9de6968](https://github.com/sentry-kubernetes/charts/commit/9de696813a5e407f4ddf3657d19519500088e7d3))

## [23.10.0](https://github.com/sentry-kubernetes/charts/compare/sentry-v23.9.1...sentry-v23.10.0) (2024-06-21)


### Features

* add insights feature flags ([#1329](https://github.com/sentry-kubernetes/charts/issues/1329)) ([6cccdbd](https://github.com/sentry-kubernetes/charts/commit/6cccdbd1a8703c6f0a0d417654358e11e7275bce))

## [23.9.1](https://github.com/sentry-kubernetes/charts/compare/sentry-v23.9.0...sentry-v23.9.1) (2024-06-17)


### Bug Fixes

* template fails when existingSecretKeys is undefined ([#1323](https://github.com/sentry-kubernetes/charts/issues/1323)) ([4808c6f](https://github.com/sentry-kubernetes/charts/commit/4808c6ff76f53820c9ec8a25fd77ac42f0395d66))

## [23.9.0](https://github.com/sentry-kubernetes/charts/compare/sentry-v23.8.0...sentry-v23.9.0) (2024-06-17)


### Features

* Configure external postgres with values from secret ([#1279](https://github.com/sentry-kubernetes/charts/issues/1279)) ([adfb64d](https://github.com/sentry-kubernetes/charts/commit/adfb64da1dcd6ba109b64fe2e7496e88d65b38a9))

## [23.8.0](https://github.com/sentry-kubernetes/charts/compare/sentry-v23.7.0...sentry-v23.8.0) (2024-06-16)


### Features

* discord integration ([#1318](https://github.com/sentry-kubernetes/charts/issues/1318)) ([d480620](https://github.com/sentry-kubernetes/charts/commit/d480620b3d60d983b239a5a59f063b05a4234ecc))

## [23.7.0](https://github.com/sentry-kubernetes/charts/compare/sentry-v23.6.0...sentry-v23.7.0) (2024-06-11)


### Features

* **deps:** update kafka helm to v29 ([#1285](https://github.com/sentry-kubernetes/charts/issues/1285)) ([5b24013](https://github.com/sentry-kubernetes/charts/commit/5b240133bd5f40202e9a86b9744eb32ed512da97))
* **deps:** update nginx docker tag to v18 ([#1301](https://github.com/sentry-kubernetes/charts/issues/1301)) ([161aed6](https://github.com/sentry-kubernetes/charts/commit/161aed65c60672972dd21c242a830f33a7d837ea))

## [23.6.0](https://github.com/sentry-kubernetes/charts/compare/sentry-v23.5.2...sentry-v23.6.0) (2024-06-10)


### Features

* add optional LogLevel parameter to sentry cleanup job and custom location snippet to nginx conf ([cd38e67](https://github.com/sentry-kubernetes/charts/commit/cd38e67121b04d5e4b060aaa97ae8378c837846e))


### Bug Fixes

* fix custom features ([#1309](https://github.com/sentry-kubernetes/charts/issues/1309)) ([7490ec3](https://github.com/sentry-kubernetes/charts/commit/7490ec3bbf1efeebf780b8f3aec3aa70d177d4e4))

## [23.5.2](https://github.com/sentry-kubernetes/charts/compare/sentry-v23.5.1...sentry-v23.5.2) (2024-06-08)


### Bug Fixes

* **snuba:** add profile_chunks to the storage sets ([#1307](https://github.com/sentry-kubernetes/charts/issues/1307)) ([df812f7](https://github.com/sentry-kubernetes/charts/commit/df812f7cf4ba28006a59c0fa49a527feac50a184))

## [23.5.1](https://github.com/sentry-kubernetes/charts/compare/sentry-v23.5.0...sentry-v23.5.1) (2024-06-07)


### Bug Fixes

* **deployment-relay:** fix relay init container volume mounts ([#861](https://github.com/sentry-kubernetes/charts/issues/861)) ([72314d5](https://github.com/sentry-kubernetes/charts/commit/72314d5a5dcc53a7562e0066a54b62ac4f9eb3e0))

## [23.5.0](https://github.com/sentry-kubernetes/charts/compare/sentry-v23.4.1...sentry-v23.5.0) (2024-06-07)


### Features

* 24.5.1 update ([6e628ad](https://github.com/sentry-kubernetes/charts/commit/6e628adc200525ebe57e9977328d8dd8b5eea471))

## [23.4.1](https://github.com/sentry-kubernetes/charts/compare/sentry-v23.4.0...sentry-v23.4.1) (2024-06-06)


### Bug Fixes

* relay topic ([1ae5f66](https://github.com/sentry-kubernetes/charts/commit/1ae5f66a24260c96ae4711f1f880220f33150148))

## [23.4.0](https://github.com/sentry-kubernetes/charts/compare/sentry-v23.3.0...sentry-v23.4.0) (2024-06-06)


### Features

* add-custom-features to configmap ([#1297](https://github.com/sentry-kubernetes/charts/issues/1297)) ([300aea0](https://github.com/sentry-kubernetes/charts/commit/300aea0dfc6293892e450d359daa63ae3619ace5))

## [23.3.0](https://github.com/sentry-kubernetes/charts/compare/sentry-v23.2.0...sentry-v23.3.0) (2024-06-04)


### Features

* topologySpreadConstraint ([#1291](https://github.com/sentry-kubernetes/charts/issues/1291)) ([bc0d4e6](https://github.com/sentry-kubernetes/charts/commit/bc0d4e64987c1ea5e4d3b1386ce45ea94c3dd15b))

## [23.2.0](https://github.com/sentry-kubernetes/charts/compare/sentry-v23.1.0...sentry-v23.2.0) (2024-06-03)


### Features

* allow to configure extra manifest through values ([#1278](https://github.com/sentry-kubernetes/charts/issues/1278)) ([3fec182](https://github.com/sentry-kubernetes/charts/commit/3fec18254de4675077f57f7783403317fc1bdad7))
* dependency update before push chart ([#1283](https://github.com/sentry-kubernetes/charts/issues/1283)) ([2c2b6c2](https://github.com/sentry-kubernetes/charts/commit/2c2b6c2d966c137a7c4251eb4c81b186f886c63e))
* supports ipv6 ([#1292](https://github.com/sentry-kubernetes/charts/issues/1292)) ([b920e3f](https://github.com/sentry-kubernetes/charts/commit/b920e3f2159f8c3e124f09cc48b29ba5aae5aedb))


### Bug Fixes

* ipv6 ([b904c79](https://github.com/sentry-kubernetes/charts/commit/b904c7935c9d51903017c1e14f74bf122cfaddde))

## [23.1.0](https://github.com/sentry-kubernetes/charts/compare/sentry-v23.0.3...sentry-v23.1.0) (2024-05-23)


### Features

* bump sentry to 24.5.0 ([#1270](https://github.com/sentry-kubernetes/charts/issues/1270)) ([7d53050](https://github.com/sentry-kubernetes/charts/commit/7d53050f8c9bda2b2fca686685e44823706dc263))


### Bug Fixes

* **worker:** workerTransactions should be disabled by default ([#1275](https://github.com/sentry-kubernetes/charts/issues/1275)) ([6090619](https://github.com/sentry-kubernetes/charts/commit/6090619d326b420f6c177114ec55a5ef84f3a075))

## [23.0.3](https://github.com/sentry-kubernetes/charts/compare/sentry-v23.0.2...sentry-v23.0.3) (2024-05-22)


### Bug Fixes

* typo in deployment-snuba-subscription-consumer-metrics.yaml [#1271](https://github.com/sentry-kubernetes/charts/issues/1271) ([d667d0c](https://github.com/sentry-kubernetes/charts/commit/d667d0cd18e36af06e6ba3050a850265df540e1d))

## [23.0.2](https://github.com/sentry-kubernetes/charts/compare/sentry-v23.0.1...sentry-v23.0.2) (2024-05-16)


### Bug Fixes

* worker hpa ([#1263](https://github.com/sentry-kubernetes/charts/issues/1263)) ([0b55646](https://github.com/sentry-kubernetes/charts/commit/0b55646e696f6be42755b58308f3127532a60d70))

## [23.0.1](https://github.com/sentry-kubernetes/charts/compare/sentry-v23.0.0...sentry-v23.0.1) (2024-05-15)


### Bug Fixes

* fix worker deployments ([#1261](https://github.com/sentry-kubernetes/charts/issues/1261)) ([eb3e7af](https://github.com/sentry-kubernetes/charts/commit/eb3e7af7f0e74fee19c10a08d1dcd193bd8de429))

## [23.0.0](https://github.com/sentry-kubernetes/charts/compare/sentry-v22.5.1...sentry-v23.0.0) (2024-05-14)


### ⚠ BREAKING CHANGES

* ingest consumers and workers separation ([#1245](https://github.com/sentry-kubernetes/charts/issues/1245))

### Features

* ingest consumers and workers separation ([#1245](https://github.com/sentry-kubernetes/charts/issues/1245)) ([5969544](https://github.com/sentry-kubernetes/charts/commit/596954497af0acef2cce4014056ca756c5eb3592))


### Bug Fixes

* fix order snuba-outcomes-billing-consumer args ([#1257](https://github.com/sentry-kubernetes/charts/issues/1257)) ([0645404](https://github.com/sentry-kubernetes/charts/commit/06454040e45fd3d13236d011802a1e6436da5f8a))

## [22.5.1](https://github.com/sentry-kubernetes/charts/compare/sentry-v22.5.0...sentry-v22.5.1) (2024-05-14)


### Bug Fixes

* fix snuba-outcomes-billing-consumer args ([#1254](https://github.com/sentry-kubernetes/charts/issues/1254)) ([ac821d6](https://github.com/sentry-kubernetes/charts/commit/ac821d61f94bcedd399b970f4c58e605c1d04602))

## [22.5.0](https://github.com/sentry-kubernetes/charts/compare/sentry-v22.4.0...sentry-v22.5.0) (2024-05-14)


### Features

* bump sentry to 24.4.2 ([#1248](https://github.com/sentry-kubernetes/charts/issues/1248)) ([c4ea3fb](https://github.com/sentry-kubernetes/charts/commit/c4ea3fbf8b646de66251f37521f744ac84228a9b))

## [22.4.0](https://github.com/sentry-kubernetes/charts/compare/sentry-v22.3.0...sentry-v22.4.0) (2024-05-08)


### Features

* checksum only for configmap contents ([#1228](https://github.com/sentry-kubernetes/charts/issues/1228)) ([97829b0](https://github.com/sentry-kubernetes/charts/commit/97829b0e0ebf705ec3083d3d01e52b4d09200946))


### Bug Fixes

* actualize Sentry consumer additional options usage ([#1244](https://github.com/sentry-kubernetes/charts/issues/1244)) ([e24d459](https://github.com/sentry-kubernetes/charts/commit/e24d4596feeb6b1fc7fe9da806d1bac2c43bcfc6))

## [22.3.0](https://github.com/sentry-kubernetes/charts/compare/sentry-v22.2.1...sentry-v22.3.0) (2024-04-29)


### Features

* Add liveness to consumers ([#1240](https://github.com/sentry-kubernetes/charts/issues/1240)) ([60aaa3d](https://github.com/sentry-kubernetes/charts/commit/60aaa3d5f485320dc3bca1161b786cb20df34b73))

## [22.2.1](https://github.com/sentry-kubernetes/charts/compare/sentry-v22.2.0...sentry-v22.2.1) (2024-04-24)


### Bug Fixes

* issues with nginx configuration for metrics ([#1232](https://github.com/sentry-kubernetes/charts/issues/1232)) ([b227a6b](https://github.com/sentry-kubernetes/charts/commit/b227a6b801d244dba9baf7180eeaaaef96dfccc3))
* sentry metrics deployment annotations ([#1239](https://github.com/sentry-kubernetes/charts/issues/1239)) ([59c6245](https://github.com/sentry-kubernetes/charts/commit/59c6245f0b79b6eafff14e301cd1378cbb432bc7))

## [22.2.0](https://github.com/sentry-kubernetes/charts/compare/sentry-v22.1.1...sentry-v22.2.0) (2024-04-17)


### Features

* added flags on individual components ([#1188](https://github.com/sentry-kubernetes/charts/issues/1188)) ([fb4d6f1](https://github.com/sentry-kubernetes/charts/commit/fb4d6f14b50c545a798b3a27012f28013d36e2d5))
* update kafka topic provisioning config ([#1134](https://github.com/sentry-kubernetes/charts/issues/1134)) ([cd508ff](https://github.com/sentry-kubernetes/charts/commit/cd508ff4e02b44189eae30d993deb3fb368fd5ee))


### Bug Fixes

* kafka.listeners.interBroker typo ([#1222](https://github.com/sentry-kubernetes/charts/issues/1222)) ([63e7062](https://github.com/sentry-kubernetes/charts/commit/63e70626a6bb0ea4caeac8dfd80b216ffcfe9c28))

## [22.1.1](https://github.com/sentry-kubernetes/charts/compare/sentry-v22.1.0...sentry-v22.1.1) (2024-04-15)


### Bug Fixes

* When set to controller only, port 9092 is not listened on ([#1218](https://github.com/sentry-kubernetes/charts/issues/1218)) ([d5cbba6](https://github.com/sentry-kubernetes/charts/commit/d5cbba6b65da9f77f78299ddc9b07c24fd7b3cef))

## [22.1.0](https://github.com/sentry-kubernetes/charts/compare/sentry-v22.0.2...sentry-v22.1.0) (2024-04-12)


### Features

* 1.0.0 ([9c5b70c](https://github.com/sentry-kubernetes/charts/commit/9c5b70c6396fd9974001e403cc11f92ccb61a011))
* 11.0.0 ([9d333e6](https://github.com/sentry-kubernetes/charts/commit/9d333e6f259dad0444b349d839cdde0187f64cc9))
* 11.2.0 ([0569872](https://github.com/sentry-kubernetes/charts/commit/05698720bc8a5eedcbaa847f766ac6a669360ec5))
* 21.4.0 release ([#356](https://github.com/sentry-kubernetes/charts/issues/356)) ([84c56ac](https://github.com/sentry-kubernetes/charts/commit/84c56ac5417c94a15ec53374b63fe56ab5e9b9a2))
* 9.0.0 ([d659dcb](https://github.com/sentry-kubernetes/charts/commit/d659dcbbea17eacf20653a6ca386ed233bd690f2))
* ability to use existingSecret for psql ([#148](https://github.com/sentry-kubernetes/charts/issues/148)) ([8c02d7a](https://github.com/sentry-kubernetes/charts/commit/8c02d7ae67c5fc0d161e739e9968b6d272acc259))
* add `existingSecret` param for Github ([#863](https://github.com/sentry-kubernetes/charts/issues/863)) ([8d43592](https://github.com/sentry-kubernetes/charts/commit/8d43592fe3f3a22e3189bd84995e5cecccd088be))
* add podLabels to Sentry hooks ([#659](https://github.com/sentry-kubernetes/charts/issues/659)) ([50b8f1e](https://github.com/sentry-kubernetes/charts/commit/50b8f1e8879e22dcf7d10035b64c8ffa2b7e41ae))
* add pvc to clickhouse ([#50](https://github.com/sentry-kubernetes/charts/issues/50)) ([197930f](https://github.com/sentry-kubernetes/charts/commit/197930f1a29bbf038351fbc72d401297140fc857))
* add sentry cleanup cronjob ([#178](https://github.com/sentry-kubernetes/charts/issues/178)) ([ae42bc4](https://github.com/sentry-kubernetes/charts/commit/ae42bc4b4783f7515cf4e8620576568a6cb6ff5c))
* add service account names for cronjobs ([#681](https://github.com/sentry-kubernetes/charts/issues/681)) ([0bc212d](https://github.com/sentry-kubernetes/charts/commit/0bc212daf3a999019d035deaed979f157f69d8ad))
* add share process namespace to hook jobs ([#688](https://github.com/sentry-kubernetes/charts/issues/688)) ([b81316d](https://github.com/sentry-kubernetes/charts/commit/b81316d4b524e19b6f2968c7552f76c47ef33368))
* add support for configuring email by env variables ([#87](https://github.com/sentry-kubernetes/charts/issues/87)) ([5e91477](https://github.com/sentry-kubernetes/charts/commit/5e91477cb61b8edb3b54734f899dd9560288417b))
* add support of GCS without secret, using GKE ServiceAccount ([#264](https://github.com/sentry-kubernetes/charts/issues/264)) ([e42656e](https://github.com/sentry-kubernetes/charts/commit/e42656ee3f5d88b9b7ba07ceba15d02c82fb544c))
* Add tolerations to user-create hook ([#615](https://github.com/sentry-kubernetes/charts/issues/615)) ([f347039](https://github.com/sentry-kubernetes/charts/commit/f347039cc4ff0f9a9e9237d9c6785d39bc46280c))
* added (partial) support for Symbolicator deployment ([#213](https://github.com/sentry-kubernetes/charts/issues/213)) ([098fdef](https://github.com/sentry-kubernetes/charts/commit/098fdef2af7b1f7b53c596cb6127d70c1d49bcea))
* added activeDeadlineSeconds to all jobs ([#683](https://github.com/sentry-kubernetes/charts/issues/683)) ([2418ba8](https://github.com/sentry-kubernetes/charts/commit/2418ba8c38a85991c9c9eb5a281bfb3d5d72a020))
* added cpu hpa for worker - remove replica if hpa ([#74](https://github.com/sentry-kubernetes/charts/issues/74)) ([5a14b8b](https://github.com/sentry-kubernetes/charts/commit/5a14b8b59c786eaa352c521dea00feb765cc2dc1))
* added different types of snuba consumers ([#83](https://github.com/sentry-kubernetes/charts/issues/83)) ([951cf38](https://github.com/sentry-kubernetes/charts/commit/951cf38c08a548e3db92d7848b6d1e6205d40b66))
* added env var config for init jobs ([#124](https://github.com/sentry-kubernetes/charts/issues/124)) ([5cec614](https://github.com/sentry-kubernetes/charts/commit/5cec61417e243ce49fe509f6bc62847add0975d0))
* added hpa for the web deployment ([#36](https://github.com/sentry-kubernetes/charts/issues/36)) ([b89ca49](https://github.com/sentry-kubernetes/charts/commit/b89ca49bf38af686bc69ff5f3ad0fb3392a2dbb2))
* added post process forwarder ([#9](https://github.com/sentry-kubernetes/charts/issues/9)) ([686613a](https://github.com/sentry-kubernetes/charts/commit/686613a31572d2bd54d5153d4d44c5ba8bc77ac2))
* added redis worker ([#10](https://github.com/sentry-kubernetes/charts/issues/10)) ([9e1cc7a](https://github.com/sentry-kubernetes/charts/commit/9e1cc7a046615856b50f17e232a9901bdc6204a9))
* allow custom mode for sentry-relay ([#197](https://github.com/sentry-kubernetes/charts/issues/197)) ([a78b5f1](https://github.com/sentry-kubernetes/charts/commit/a78b5f1f061fad910cd679bb9eca083f04607de6))
* allow some snuba deployments to be pushed as hooks ([#198](https://github.com/sentry-kubernetes/charts/issues/198)) ([9bda4ee](https://github.com/sentry-kubernetes/charts/commit/9bda4ee401664382f54932adfd7135820bc45d1d))
* allow to configure running relay as a hook ([#183](https://github.com/sentry-kubernetes/charts/issues/183)) ([652a838](https://github.com/sentry-kubernetes/charts/commit/652a8386a4f84a0fa8319b7afda3d3c1784c3d06))
* allow to specify Recreate strategy type for sentry-web ([#216](https://github.com/sentry-kubernetes/charts/issues/216)) ([0179c79](https://github.com/sentry-kubernetes/charts/commit/0179c79fe490e1f44a3e54f6bcc8ff0f37a78d92))
* allows revisionHistoryLimit ([#339](https://github.com/sentry-kubernetes/charts/issues/339)) ([65545c8](https://github.com/sentry-kubernetes/charts/commit/65545c87c98c3af930897f08f4d095f67beb3027))
* bump sentry dependencies ([#1099](https://github.com/sentry-kubernetes/charts/issues/1099)) ([dccd183](https://github.com/sentry-kubernetes/charts/commit/dccd183760ee92aab2592333d8dc1a23d7411466))
* configure Slack based on current documentation ([#189](https://github.com/sentry-kubernetes/charts/issues/189)) ([5c4447c](https://github.com/sentry-kubernetes/charts/commit/5c4447cd5f2055ac7356face9e19fa552adb5e77))
* december release ([#245](https://github.com/sentry-kubernetes/charts/issues/245)) ([ec588a9](https://github.com/sentry-kubernetes/charts/commit/ec588a94520555e512b1b931eb5799e6d08293c9))
* distributed tables v2 ([#588](https://github.com/sentry-kubernetes/charts/issues/588)) ([cfe7d73](https://github.com/sentry-kubernetes/charts/commit/cfe7d736278feeeb72189efb841a6099685ed1dd))
* history limits for cronjobs ([#682](https://github.com/sentry-kubernetes/charts/issues/682)) ([f13da86](https://github.com/sentry-kubernetes/charts/commit/f13da86b541aa8645f1e7a72e54ea3df5ad6f7b2))
* hpa for snuba ([#42](https://github.com/sentry-kubernetes/charts/issues/42)) ([36a6e10](https://github.com/sentry-kubernetes/charts/commit/36a6e10f87e2b124b2a6527901ac49454a6a29e2))
* ingress ([#19](https://github.com/sentry-kubernetes/charts/issues/19)) ([a5fad21](https://github.com/sentry-kubernetes/charts/commit/a5fad21db773e664f2b51df0522f411b9be30698))
* initial beta 0.5.0 ([51866df](https://github.com/sentry-kubernetes/charts/commit/51866df56c518d28c74937c6b5119cd683d667f0))
* kafka fix db check ([a148a57](https://github.com/sentry-kubernetes/charts/commit/a148a57d7480e23adc912fe8700914792bea9807))
* kafka ha ([#35](https://github.com/sentry-kubernetes/charts/issues/35)) ([3b581f0](https://github.com/sentry-kubernetes/charts/commit/3b581f0b33d5d7d297c8bf110c70b7ae4b0796d2))
* **kafka:** enable kraft ([#1179](https://github.com/sentry-kubernetes/charts/issues/1179)) ([b01b26a](https://github.com/sentry-kubernetes/charts/commit/b01b26a15247daad77828d67b1cfa15a7c9cc95c))
* lint ([#1](https://github.com/sentry-kubernetes/charts/issues/1)) ([680d142](https://github.com/sentry-kubernetes/charts/commit/680d142670ae1972a27d473837b0884dc9f536f9))
* org subdomain disabled per default ([#248](https://github.com/sentry-kubernetes/charts/issues/248)) ([0819e79](https://github.com/sentry-kubernetes/charts/commit/0819e79bf71d2af2dc23a9347ee242945757a4d2))
* pass entire symbolicator config as yaml ([#335](https://github.com/sentry-kubernetes/charts/issues/335)) ([20d23b5](https://github.com/sentry-kubernetes/charts/commit/20d23b5369dd9ebca7c8fb7cd0f63c8012ef45b3))
* postgresql - and fix some issues ([#5](https://github.com/sentry-kubernetes/charts/issues/5)) ([70fa92d](https://github.com/sentry-kubernetes/charts/commit/70fa92dde31c7488f9303acfbd79813760fcebf7))
* profiling support ([#938](https://github.com/sentry-kubernetes/charts/issues/938)) ([b58f8a3](https://github.com/sentry-kubernetes/charts/commit/b58f8a34bbfab27ab0ff10bddcd8c23033b230fc))
* removal of hook resources can be configured ([#223](https://github.com/sentry-kubernetes/charts/issues/223)) ([32232da](https://github.com/sentry-kubernetes/charts/commit/32232da29ca7431084aea8048ef84da0ac1794f6))
* secret key generation ([#672](https://github.com/sentry-kubernetes/charts/issues/672)) ([559afc9](https://github.com/sentry-kubernetes/charts/commit/559afc90bfc7e2fdfd8b2d471ade5293f56c94d7))
* sentry 20.10.1 ([#211](https://github.com/sentry-kubernetes/charts/issues/211)) ([cb9c844](https://github.com/sentry-kubernetes/charts/commit/cb9c844592ac678fa1c86faafcf520a040f7d814))
* sentry 20.7.2 ([#126](https://github.com/sentry-kubernetes/charts/issues/126)) ([43197bc](https://github.com/sentry-kubernetes/charts/commit/43197bcefc51efc92eb51bac6efc4198e5b5c0f7))
* sentry 20.9.0 ([#182](https://github.com/sentry-kubernetes/charts/issues/182)) ([c7934ae](https://github.com/sentry-kubernetes/charts/commit/c7934aec90eb1231d6ad21d052ae50dca3c8bf21))
* sentry 22.10 & split post-process-forwarder ([#766](https://github.com/sentry-kubernetes/charts/issues/766)) ([ca611ef](https://github.com/sentry-kubernetes/charts/commit/ca611efde92be5deb7756ae05837e6ff1402f839))
* sentry january ([#291](https://github.com/sentry-kubernetes/charts/issues/291)) ([be0ba2a](https://github.com/sentry-kubernetes/charts/commit/be0ba2aa9baebe24bec119038e83fa6ffc56d75b))
* sentry june release ([#910](https://github.com/sentry-kubernetes/charts/issues/910)) ([96eb327](https://github.com/sentry-kubernetes/charts/commit/96eb3278775032e594bbf893f4fd4ef6d958a3de))
* sentry march release ([#333](https://github.com/sentry-kubernetes/charts/issues/333)) ([7408226](https://github.com/sentry-kubernetes/charts/commit/74082260202b8af97822d03b79f43cca61da9ca0))
* sentry may 2022 ([#623](https://github.com/sentry-kubernetes/charts/issues/623)) ([2a4cb0c](https://github.com/sentry-kubernetes/charts/commit/2a4cb0c4afe16720475f05405aac08e718acdead))
* **sentry:** adding statsd backend + prometheus-operator support ([#85](https://github.com/sentry-kubernetes/charts/issues/85)) ([7daee19](https://github.com/sentry-kubernetes/charts/commit/7daee1999c61934f937c751855d2746a78425456))
* **sentry:** bump clickhouse image to 19.17 ([#143](https://github.com/sentry-kubernetes/charts/issues/143)) ([3b80f57](https://github.com/sentry-kubernetes/charts/commit/3b80f578d8647ed1a549590c04376ed76cc4473f))
* **sentry:** enable snuba transactions consumer ([#142](https://github.com/sentry-kubernetes/charts/issues/142)) ([0203628](https://github.com/sentry-kubernetes/charts/commit/0203628f4c9d6e255ce163ceaa7997b89365c162))
* **sentry:** use AppVersion as the default image tag ([#141](https://github.com/sentry-kubernetes/charts/issues/141)) ([a0e79cf](https://github.com/sentry-kubernetes/charts/commit/a0e79cf8c834c79c1018c02452274a6f43d5ef73))
* separate config for external services ([#66](https://github.com/sentry-kubernetes/charts/issues/66)) ([5e80eba](https://github.com/sentry-kubernetes/charts/commit/5e80ebab63d8c78868edd63810789b47468b2986))
* smtp support use-ssl options ([#494](https://github.com/sentry-kubernetes/charts/issues/494)) ([bf8fdd5](https://github.com/sentry-kubernetes/charts/commit/bf8fdd596861a22bff74299f9d23b60644d7a08f))
* support for sentry relay & sentry 20.7.2 ([#144](https://github.com/sentry-kubernetes/charts/issues/144)) ([7ae3651](https://github.com/sentry-kubernetes/charts/commit/7ae365187da883efd891c351dc75c2e566112718))
* support partitions parameter for consumer events ([#566](https://github.com/sentry-kubernetes/charts/issues/566)) ([26128fe](https://github.com/sentry-kubernetes/charts/commit/26128fe808c33008c1660fda1271cef4381bf1fa))
* supports different values between redis&rabbitmq ([#16](https://github.com/sentry-kubernetes/charts/issues/16)) ([da70618](https://github.com/sentry-kubernetes/charts/commit/da7061889e42d66ce1085338f635fcbf9ed4c19d))
* supports github apps - sso ([#17](https://github.com/sentry-kubernetes/charts/issues/17)) ([90829bd](https://github.com/sentry-kubernetes/charts/commit/90829bd1bff956ae1d6815b1837985931b623d10))
* supports persistent workers ([#15](https://github.com/sentry-kubernetes/charts/issues/15)) ([ca63322](https://github.com/sentry-kubernetes/charts/commit/ca6332289753f333cfc3a0ce39942f7092eef01f))
* update clickhouse version ([#332](https://github.com/sentry-kubernetes/charts/issues/332)) ([3a6b012](https://github.com/sentry-kubernetes/charts/commit/3a6b0123d564ea10d65845123c6cec61659ea9f2))
* update rabbitmq-ha to allow setting affinity ([#110](https://github.com/sentry-kubernetes/charts/issues/110)) ([fe269f2](https://github.com/sentry-kubernetes/charts/commit/fe269f253d46f763e080c084b92fa4f8da296964))
* update Sentry & Snuba ([#80](https://github.com/sentry-kubernetes/charts/issues/80)) ([3f28140](https://github.com/sentry-kubernetes/charts/commit/3f281400fde3f06062a823ee06ea5474cfa261a3))
* update sentry to 20.7.1 ([#122](https://github.com/sentry-kubernetes/charts/issues/122)) ([e1014b8](https://github.com/sentry-kubernetes/charts/commit/e1014b8b49626818cf80329e445f48b2f68390a9))
* update sentry to february release ([#306](https://github.com/sentry-kubernetes/charts/issues/306)) ([e8d13dc](https://github.com/sentry-kubernetes/charts/commit/e8d13dc8afac5c878d85cf96f318a7fa316243be))
* update sentry&snuba ([#72](https://github.com/sentry-kubernetes/charts/issues/72)) ([3cae6b9](https://github.com/sentry-kubernetes/charts/commit/3cae6b9ae6f956ef9de8138265f3e18c95638bf5))
* update sentry&snuba images ([#53](https://github.com/sentry-kubernetes/charts/issues/53)) ([0427a1f](https://github.com/sentry-kubernetes/charts/commit/0427a1fc098c72a1b8b3a7af8a376247790f899b))
* updated clickhouse chart version ([6bdcea8](https://github.com/sentry-kubernetes/charts/commit/6bdcea8690d207b29e610f28363841cf0b0912c9))
* updated clickhouse to 1.4.0 ([17aa7ef](https://github.com/sentry-kubernetes/charts/commit/17aa7ef5a442986393ee473b9bcb439c15c866e9))
* updated kafka helm chart and supports kafka without zookeeper ([#888](https://github.com/sentry-kubernetes/charts/issues/888)) ([d8fab37](https://github.com/sentry-kubernetes/charts/commit/d8fab37ef108dea173e6e7412fd030bd977af754))
* updated tags to 20.8.0 ([#167](https://github.com/sentry-kubernetes/charts/issues/167)) ([91c7d41](https://github.com/sentry-kubernetes/charts/commit/91c7d41e14cb57d0951d7d88eafa721ccf430bb5))
* updating Sentry config.yaml to support actual yaml. ([#186](https://github.com/sentry-kubernetes/charts/issues/186)) ([945e4c0](https://github.com/sentry-kubernetes/charts/commit/945e4c0e44facbeae402fbb5f32a7ce05dd53dfe))
* upgrade kafka for more stability ([#246](https://github.com/sentry-kubernetes/charts/issues/246)) ([898fbcd](https://github.com/sentry-kubernetes/charts/commit/898fbcd72f13e5d139456d56d3a87f6a0f6e8833))
* upgrade sentry to 21.5.1 ([#389](https://github.com/sentry-kubernetes/charts/issues/389)) ([656d112](https://github.com/sentry-kubernetes/charts/commit/656d11265224a122a34eb5b043115af018f3c610))
* upgrade sentry to 21.6.1 ([#416](https://github.com/sentry-kubernetes/charts/issues/416)) ([2234ab9](https://github.com/sentry-kubernetes/charts/commit/2234ab90fdd66a76813d78c541b6331b79839d96))
* upgrade Sentry version to 21.3.1 ([#350](https://github.com/sentry-kubernetes/charts/issues/350)) ([13f4537](https://github.com/sentry-kubernetes/charts/commit/13f4537e4df3d67b4be82234309a580d2c4c9af4))


### Bug Fixes

* 419 using correct block indicator ([#420](https://github.com/sentry-kubernetes/charts/issues/420)) ([d4ff2b7](https://github.com/sentry-kubernetes/charts/commit/d4ff2b7476c91fb8f1120a5465203d6b8200eeca))
* add dbcheck job that ensures that clickhouse and kafka are up before proceeding ([#267](https://github.com/sentry-kubernetes/charts/issues/267)) ([8bdd076](https://github.com/sentry-kubernetes/charts/commit/8bdd076d1b45bfcfc393b68726f5b55b597a6756))
* add legacyApp field for slack ([#125](https://github.com/sentry-kubernetes/charts/issues/125)) ([dfe8a12](https://github.com/sentry-kubernetes/charts/commit/dfe8a1262989a44cbcdb0f79d11435dc13478740))
* add noStrictOffsetReset with ingestConsumer ([#1186](https://github.com/sentry-kubernetes/charts/issues/1186)) ([f4d2f74](https://github.com/sentry-kubernetes/charts/commit/f4d2f74431cb3d041b248729b75bd474ec6ef455))
* add performance-view in configmap-sentry.yaml ([#133](https://github.com/sentry-kubernetes/charts/issues/133)) ([72c41d2](https://github.com/sentry-kubernetes/charts/commit/72c41d2f70d70a66b9b8d1741eed098c19c03a0a))
* allow Redis only and fix Redis password use in BROKER_URL ([#24](https://github.com/sentry-kubernetes/charts/issues/24)) ([20c4ca1](https://github.com/sentry-kubernetes/charts/commit/20c4ca1baac88cefb8bcd7cf76de15013003807c))
* Apply appropriate batch apiVersion based on kubernetes version ([#700](https://github.com/sentry-kubernetes/charts/issues/700)) ([4128412](https://github.com/sentry-kubernetes/charts/commit/412841202e136f64266139132ebc96037a43d9ca))
* charts path ([2d7bcc9](https://github.com/sentry-kubernetes/charts/commit/2d7bcc98abbc367c62643bd0cb1d02bce52f893a))
* clickhouse database init "Bad get: has UInt64" because of '-' character in cluster name ([#204](https://github.com/sentry-kubernetes/charts/issues/204)) ([9f93287](https://github.com/sentry-kubernetes/charts/commit/9f932872ce44f8b4d3db5e7555cf3637be1a6d9d))
* dbCheck image can be pulled from custom repository ([#358](https://github.com/sentry-kubernetes/charts/issues/358)) ([#359](https://github.com/sentry-kubernetes/charts/issues/359)) ([6145595](https://github.com/sentry-kubernetes/charts/commit/61455956b1db50fc5b2af47a673d9759c86308db))
* distant clickhouse image ([5da5d86](https://github.com/sentry-kubernetes/charts/commit/5da5d866261db73d38437bdbbdf20057bd61b1df))
* django.security.csrf issue ([#155](https://github.com/sentry-kubernetes/charts/issues/155)) ([a680856](https://github.com/sentry-kubernetes/charts/commit/a680856c0208f4df626e05163f754442f59fca10))
* do not complete the user-create on error ([#58](https://github.com/sentry-kubernetes/charts/issues/58)) ([7b925fe](https://github.com/sentry-kubernetes/charts/commit/7b925feb8b0d28a2a47276ae666462d9107a4a9d))
* empty email values were crashing the pods ([#12](https://github.com/sentry-kubernetes/charts/issues/12)) ([5b6101f](https://github.com/sentry-kubernetes/charts/commit/5b6101fb0860ec0a8fff2dca86d1affc9b5d9656))
* erroneous formatting in relay configmap ([#203](https://github.com/sentry-kubernetes/charts/issues/203)) ([a42d41f](https://github.com/sentry-kubernetes/charts/commit/a42d41fe502c8a8e2394330cbf1c03eddc9d8d20)), closes [#202](https://github.com/sentry-kubernetes/charts/issues/202)
* external db ([#34](https://github.com/sentry-kubernetes/charts/issues/34)) ([87bfc2c](https://github.com/sentry-kubernetes/charts/commit/87bfc2c7d2e2713ac0e5e39d6a7fca89ef32ba9a))
* external postgres host ([#41](https://github.com/sentry-kubernetes/charts/issues/41)) ([bc6f5ab](https://github.com/sentry-kubernetes/charts/commit/bc6f5ab62ec1fb43d6b63254f6e6493344365acd))
* Fix wrong service account for ingest-profiles deployment ([#966](https://github.com/sentry-kubernetes/charts/issues/966)) ([cead469](https://github.com/sentry-kubernetes/charts/commit/cead469eb418e8ae110f60c173ab0bb9f74e4cc3))
* force UTC on clickhouse ([545052d](https://github.com/sentry-kubernetes/charts/commit/545052d90bb26559293e185f3436a671fa4ec2d4))
* gcs filestore ([#18](https://github.com/sentry-kubernetes/charts/issues/18)) ([5249630](https://github.com/sentry-kubernetes/charts/commit/524963031fb29932992d166cb3ae06237c6cc19e))
* github secret extra quotation mark([#415](https://github.com/sentry-kubernetes/charts/issues/415)) ([44cea73](https://github.com/sentry-kubernetes/charts/commit/44cea735054165be3e613dc142e9eb6f4136b032))
* Healthcheck for Relay backend was missing so when using .Values.ingress.regexPathStyle: gke will throw an error that template is missing ([#612](https://github.com/sentry-kubernetes/charts/issues/612)) ([9da34de](https://github.com/sentry-kubernetes/charts/commit/9da34de847716a74fd7e6f347c5bc723f7f00bc5))
* hide content-disposition header on /static for Safari ([#1051](https://github.com/sentry-kubernetes/charts/issues/1051)) ([a688d20](https://github.com/sentry-kubernetes/charts/commit/a688d20687f4c24cf9dd9dd4d54dc108b6dba2c7))
* hpa names to make them unique ([#102](https://github.com/sentry-kubernetes/charts/issues/102)) ([ab9126a](https://github.com/sentry-kubernetes/charts/commit/ab9126a20e74b816e8473e08e4dcd6eacca4224b))
* image pull policy ([#184](https://github.com/sentry-kubernetes/charts/issues/184)) ([0175798](https://github.com/sentry-kubernetes/charts/commit/0175798cf9982daef6f28771ce2dc6f4c688ff8d))
* imagePullPolicy ingest consumer ([b036dc1](https://github.com/sentry-kubernetes/charts/commit/b036dc1493d47e0888bd7d89e0ab8f5a26ff2a06))
* kafka env if disabled ([#43](https://github.com/sentry-kubernetes/charts/issues/43)) ([df96f9e](https://github.com/sentry-kubernetes/charts/commit/df96f9e8c84089e4c853651be4defad58ad40494))
* make ingress, rbac compatible with latest k8s versions ([#114](https://github.com/sentry-kubernetes/charts/issues/114)) ([8d2f319](https://github.com/sentry-kubernetes/charts/commit/8d2f3196fe797a301ba6ebb21b793f3030d70962))
* make the relay paths in the ingress compatible with traefik ([#274](https://github.com/sentry-kubernetes/charts/issues/274)) ([1707630](https://github.com/sentry-kubernetes/charts/commit/17076301717c4beafacf0febb64bb474b3897f6e))
* Make the snuba api liveness and readiness timeouts configurable ([#409](https://github.com/sentry-kubernetes/charts/issues/409)) ([9625fbe](https://github.com/sentry-kubernetes/charts/commit/9625fbe471aa751722e0daace15faa4d3a6e4fd9))
* **memcache:** do not set SERVER_MAX_VALUE_LENGTH with latest django versions ([#1131](https://github.com/sentry-kubernetes/charts/issues/1131)) ([1307658](https://github.com/sentry-kubernetes/charts/commit/1307658414ad84668b658c7411e952d487944589))
* Missing config for snuba migration ([#948](https://github.com/sentry-kubernetes/charts/issues/948)) ([becf6b5](https://github.com/sentry-kubernetes/charts/commit/becf6b5bcb7774e63c5c250ca0a99a4da289667f))
* missing profiling config ([#1038](https://github.com/sentry-kubernetes/charts/issues/1038)) ([5d21ac2](https://github.com/sentry-kubernetes/charts/commit/5d21ac2b358664d63560faf99d9a7108f4287c5a))
* new deployments should be sent as hook as well ([#229](https://github.com/sentry-kubernetes/charts/issues/229)) ([29cb2c9](https://github.com/sentry-kubernetes/charts/commit/29cb2c911620cbb179b34a7d6fc76c7e882e8c69))
* new dist tables ([#282](https://github.com/sentry-kubernetes/charts/issues/282)) ([6dd45b7](https://github.com/sentry-kubernetes/charts/commit/6dd45b7def24e291126eabfe883a033a9706dd87))
* nginx configmap name ([#185](https://github.com/sentry-kubernetes/charts/issues/185)) ([3e86a9a](https://github.com/sentry-kubernetes/charts/commit/3e86a9a3f09ce942782ab745009f9265f6d6574c))
* nginx static path not pass proxy ([#1060](https://github.com/sentry-kubernetes/charts/issues/1060)) ([ae07c35](https://github.com/sentry-kubernetes/charts/commit/ae07c35e642def515eacdaf0bd95d507fb3e8249))
* no events found ([6b85730](https://github.com/sentry-kubernetes/charts/commit/6b8573087a6363223335d8a5569e0811cb961858))
* pass postgresql password to user-create job ([#55](https://github.com/sentry-kubernetes/charts/issues/55)) ([4778949](https://github.com/sentry-kubernetes/charts/commit/4778949104db6192dfa09e83f43206337e754b34))
* pass postgress password to db-init ([#52](https://github.com/sentry-kubernetes/charts/issues/52)) ([73b5df2](https://github.com/sentry-kubernetes/charts/commit/73b5df227d1e996c24c8f301038d06f23e022862))
* persistent volume discrepancy ([#30](https://github.com/sentry-kubernetes/charts/issues/30)) ([3f70746](https://github.com/sentry-kubernetes/charts/commit/3f7074668300c0c80a866eda56982ef8c7886025))
* postgresql existing secret path ([#1004](https://github.com/sentry-kubernetes/charts/issues/1004)) ([68614e1](https://github.com/sentry-kubernetes/charts/commit/68614e1691e1d3a0f3ad6d80ca675e395fc439f7))
* rabbitmq connection ([#57](https://github.com/sentry-kubernetes/charts/issues/57)) ([0b18d52](https://github.com/sentry-kubernetes/charts/commit/0b18d52563e1938555395d994004d37b5b024102))
* rabbitmq to support new bitnami chart ([#320](https://github.com/sentry-kubernetes/charts/issues/320)) ([2936e90](https://github.com/sentry-kubernetes/charts/commit/2936e9075cc82c7aa2ad2fcdc2c11df8911d4e91))
* relay connection to sentry if port not 9000 ([#181](https://github.com/sentry-kubernetes/charts/issues/181)) ([44aaabf](https://github.com/sentry-kubernetes/charts/commit/44aaabf4b925a65f77ab2e2945f6ec82c36afe34))
* relay deployment ([#179](https://github.com/sentry-kubernetes/charts/issues/179)) ([d8e34f5](https://github.com/sentry-kubernetes/charts/commit/d8e34f569e01cb04e4c17d5a03313c95b2cbf642))
* replay session ([#1054](https://github.com/sentry-kubernetes/charts/issues/1054)) ([78c93e5](https://github.com/sentry-kubernetes/charts/commit/78c93e5996f7bc26ea4148e0aa8cb6c4b0b3aafb))
* reverted 20.7.2 (not working properly without relay) ([#128](https://github.com/sentry-kubernetes/charts/issues/128)) ([a61af24](https://github.com/sentry-kubernetes/charts/commit/a61af243e3adb85a2c89e6b0755dae250830a1d4))
* run Snuba in Distributed Dataset Mode ([#70](https://github.com/sentry-kubernetes/charts/issues/70)) ([7188166](https://github.com/sentry-kubernetes/charts/commit/7188166710aaaab6013c087c6091738731bb7ecf))
* sentry secret deleted ([#748](https://github.com/sentry-kubernetes/charts/issues/748)) ([7d90dda](https://github.com/sentry-kubernetes/charts/commit/7d90ddaa49c3b629049620d08b582bedbcd89b79))
* sentry version ([81bbe82](https://github.com/sentry-kubernetes/charts/commit/81bbe825b9bf52495b1eb6ded1d5d5dd1dfd04ff))
* sentry web options ([#406](https://github.com/sentry-kubernetes/charts/issues/406)) ([73d4213](https://github.com/sentry-kubernetes/charts/commit/73d4213d255746c1a05eb5b7bd23801489e416da))
* Set the right service account for ingest occurrences deployment ([#988](https://github.com/sentry-kubernetes/charts/issues/988)) ([a7d8390](https://github.com/sentry-kubernetes/charts/commit/a7d8390d46537dd904d2a9745358a894e304a6df))
* snuba - custom redis ([#23](https://github.com/sentry-kubernetes/charts/issues/23)) ([04ad7fa](https://github.com/sentry-kubernetes/charts/commit/04ad7fa1db3e52da3aeeb8751f17b9d7ff023e0a))
* snuba connection ([#13](https://github.com/sentry-kubernetes/charts/issues/13)) ([9bf1ffb](https://github.com/sentry-kubernetes/charts/commit/9bf1ffbddd4f8bc917d7602ad11b1c00443038b8))
* space in relay config ([4c281c4](https://github.com/sentry-kubernetes/charts/commit/4c281c400566d3d35e6dd50582cdbffe293c9390))
* special characters in email and password ([#165](https://github.com/sentry-kubernetes/charts/issues/165)) ([72df379](https://github.com/sentry-kubernetes/charts/commit/72df379355382d620fa3d28bf9f859d7938542cf))
* symbolicator usage ([#173](https://github.com/sentry-kubernetes/charts/issues/173)) ([4e457e3](https://github.com/sentry-kubernetes/charts/commit/4e457e3b228a41602a30ad5b4920bce3e673b474))
* templating error when disabling hooks ([#76](https://github.com/sentry-kubernetes/charts/issues/76)) ([f0a8e3f](https://github.com/sentry-kubernetes/charts/commit/f0a8e3f47a16895f0a1e11c6955cb5816454ebe2))
* the default clickhouse installation is distributed, only turn on single node when clickhouse is disabled ([#624](https://github.com/sentry-kubernetes/charts/issues/624)) ([d923eab](https://github.com/sentry-kubernetes/charts/commit/d923eab060512957e91217f9029cf5d3286fc2e6))
* turn off clickhouse backups to fix default installation ([#292](https://github.com/sentry-kubernetes/charts/issues/292)) ([45cc76d](https://github.com/sentry-kubernetes/charts/commit/45cc76da1c03ffe4c9e46f4be2c8d5b5c41f907d))
* update clickhouse chart to the latest version ([#103](https://github.com/sentry-kubernetes/charts/issues/103)) ([9b64422](https://github.com/sentry-kubernetes/charts/commit/9b6442221627531bf4ce2a60b559475f7d4070ba))
* updated gke BackendConfig with new values added on [#432](https://github.com/sentry-kubernetes/charts/issues/432) pull request ([#445](https://github.com/sentry-kubernetes/charts/issues/445)) ([cedbd69](https://github.com/sentry-kubernetes/charts/commit/cedbd69290c1b52c39f19da5088e34ebf276a6d3))
* worker should work with both redis & rabbitmq ([#48](https://github.com/sentry-kubernetes/charts/issues/48)) ([f4ab657](https://github.com/sentry-kubernetes/charts/commit/f4ab65782ac5603ae6df8df6d49220a9461f423a))
* **worker:** fix liveness probe changes ([#1139](https://github.com/sentry-kubernetes/charts/issues/1139)) ([1042c3d](https://github.com/sentry-kubernetes/charts/commit/1042c3dcc583ca09b69dd0ce23c1869ea2ac6ba2))
* zookeeper enabled per default ([ca18057](https://github.com/sentry-kubernetes/charts/commit/ca18057666d14159d968d9d0a10ee5a6b406f723))

## 22.0.2 (2024-04-12)

Automated releases
