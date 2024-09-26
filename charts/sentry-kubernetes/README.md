# sentry-kubernetes

[sentry-kubernetes](https://github.com/getsentry/sentry-kubernetes) is a utility that pushes Kubernetes events to [Sentry](https://sentry.io).

# Installation:

```console
$ helm install sentry/sentry-kubernetes --name my-release --set sentry.dsn=<your-dsn>
```

## Configuration

The following table lists the configurable parameters of the sentry-kubernetes chart and their default values:

| Parameter               | Description                                                                                                                 | Default                       |
| ----------------------- | --------------------------------------------------------------------------------------------------------------------------- | ----------------------------- |
| `sentry.dsn`            | Sentry DSN                                                                                                                  | Empty                         |
| `existingSecret`        | Existing secret to read DSN from                                                                                            | Empty                         |
| `sentry.environment`    | Sentry environment                                                                                                          | Empty                         |
| `sentry.release`        | Sentry release version                                                                                                      | Empty                         |
| `sentry.logLevel`       | Sentry log level (trace, debug, info, warn, error, disabled)                                                                | `info`                        |
| `sentry.watchNamespaces`| Comma-separated list of namespaces to watch (set to `__all__` to watch all namespaces)                                      | `default`                     |
| `sentry.watchHistorical`| Set to `1` to report all existing (old) events, `0` to only report new events                                               | `0`                           |
| `sentry.clusterConfigType`      | Cluster configuration type (`auto`, `in-cluster`, `out-cluster`)                                                            | `auto`                        |
| `sentry.kubeconfigPath`         | Filesystem path to the kubeconfig used to connect to the cluster (used if `clusterConfigType` is `out-cluster`)             | Empty                         |
| `sentry.monitorCronjobs`        | Set to `1` to enable Sentry Crons integration for CronJob objects                                                           | `0`                           |
| `sentry.customDsns`             | Set to `1` to enable custom DSN specified in annotations with the key `k8s.sentry.io/dsn`                                   | `0`                           |
| `image.repository`      | Container image name                                                                                                        | `getsentry/sentry-kubernetes` |
| `image.tag`             | Container image tag                                                                                                         | `latest`                      |
| `rbac.create`           | If `true`, create and use RBAC resources                                                                                    | `true`                        |
| `serviceAccount.name`   | Service account to be used. If not set and serviceAccount.create is `true`, a name is generated using the fullname template | Empty                         |
| `serviceAccount.create` | If true, create a new service account                                                                                       | `true`                        |
| `priorityClassName`     | pod priorityClassName                                                                                                       | Empty                         |
| `resources`                     | Resource requests and limits                                                                                                | `{}`                          |
| `nodeSelector`                  | Node labels for pod assignment                                                                                              | `{}`                          |
| `tolerations`                   | Tolerations for pod assignment                                                                                              | `[]`                          |
| `podAnnotations`                | Annotations to add to the pod                                                                                               | `{}`                          |
| `podLabels`                     | Additional labels to add to the pod                                                                                         | `{}`                          |
| `rbac.custom_rules` | List of custom RBAC rules to extend default permissions. Each rule can specify `apiGroups`, `resources`, and `verbs`. | `[]`    |
| `sentry.appendEnv`  | List of custom environment variables to append. Each item can specify a `name` and either a `value` or a `valueFrom` reference. | `[]`    |

## Usage

After installing the chart, you can configure various aspects of the sentry-kubernetes integration by modifying the `values.yaml` file or using `--set` flags during installation.

### Example `values.yaml` Configuration

Here's an example `values.yaml` that sets up sentry-kubernetes with custom configurations (remove unused values for default values):

```yaml

sentry:
  dsn: <your-dsn>
  environment: production
  release: "1.0.0"
  logLevel: info
  watchNamespaces: "default,production"
  watchHistorical: "1"
  clusterConfigType: auto
  kubeconfigPath: "/path/to/kubeconfig"
  monitorCronjobs: "1"
  customDsns: "1"
  appendEnv:
    - name: SENTRY_NEW_ENV_1
      value: "newvalues"
    - name: SENTRY_NEW_ENV_2
      value: "newvalues"


rbac:
  # Specifies whether RBAC resources should be created
  create: true
  # Will replace the default rules
  custom_rules:
   - verbs:
       - get
       - list
       - watch
     apiGroups:
       - 'apps'
       - 'batch'
       - ''
     resources:
       - events
       - jobs
       - deployments
       - replicasets
       - cronjobs
       - pods

resources:
  limits:
    cpu: 500m
    memory: 512Mi
  requests:
    cpu: 250m
    memory: 256Mi

