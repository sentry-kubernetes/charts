# Changelog

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
* add podLables to Sentry hooks ([#659](https://github.com/sentry-kubernetes/charts/issues/659)) ([50b8f1e](https://github.com/sentry-kubernetes/charts/commit/50b8f1e8879e22dcf7d10035b64c8ffa2b7e41ae))
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
* erroneous formating in relay configmap ([#203](https://github.com/sentry-kubernetes/charts/issues/203)) ([a42d41f](https://github.com/sentry-kubernetes/charts/commit/a42d41fe502c8a8e2394330cbf1c03eddc9d8d20)), closes [#202](https://github.com/sentry-kubernetes/charts/issues/202)
* external db ([#34](https://github.com/sentry-kubernetes/charts/issues/34)) ([87bfc2c](https://github.com/sentry-kubernetes/charts/commit/87bfc2c7d2e2713ac0e5e39d6a7fca89ef32ba9a))
* external postgres host ([#41](https://github.com/sentry-kubernetes/charts/issues/41)) ([bc6f5ab](https://github.com/sentry-kubernetes/charts/commit/bc6f5ab62ec1fb43d6b63254f6e6493344365acd))
* Fix wrong service account for ingest-profiles deployment ([#966](https://github.com/sentry-kubernetes/charts/issues/966)) ([cead469](https://github.com/sentry-kubernetes/charts/commit/cead469eb418e8ae110f60c173ab0bb9f74e4cc3))
* force UTC on clickhouse ([545052d](https://github.com/sentry-kubernetes/charts/commit/545052d90bb26559293e185f3436a671fa4ec2d4))
* gcs filestore ([#18](https://github.com/sentry-kubernetes/charts/issues/18)) ([5249630](https://github.com/sentry-kubernetes/charts/commit/524963031fb29932992d166cb3ae06237c6cc19e))
* github secret extra quotation mark([#415](https://github.com/sentry-kubernetes/charts/issues/415)) ([44cea73](https://github.com/sentry-kubernetes/charts/commit/44cea735054165be3e613dc142e9eb6f4136b032))
* Healthcheck for Relay backend was missing so when using .Values.ingress.regexPathStyle: gke will throw an error that templat is missing ([#612](https://github.com/sentry-kubernetes/charts/issues/612)) ([9da34de](https://github.com/sentry-kubernetes/charts/commit/9da34de847716a74fd7e6f347c5bc723f7f00bc5))
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
