# ClickHouse prepare hook

The optional `clickhouse-prepare` Job runs before Helm install and upgrade. It
validates the external ClickHouse cluster topology, creates the Snuba database,
can provision the runtime user and grants, verifies required user settings, and
runs a distributed INSERT smoke test.

The hook is disabled by default. It requires `hooks.enabled: true`, a valid
ClickHouse cluster name, and the account configured by `externalClickhouse`
must be allowed to query `system.clusters` and perform the selected operations.

```yaml
hooks:
  enabled: true

externalClickhouse:
  host: clickhouse.example.svc
  tcpPort: 9000
  database: sentry
  username: sentry
  existingSecret: clickhouse-runtime
  existingSecretKey: password
  clusterName: sentry_local
  distributedClusterName: sentry_distributed

  prepare:
    enabled: true
    expectedShards: 2
    expectedReplicasPerShard: 3
    runtimeUser:
      enabled: true
      grantAll: false
    settings:
      apply: true
      verify: true
    distributedInsertTest:
      enabled: true
```

The Job does not have separate credentials. It uses
`externalClickhouse.username` together with `externalClickhouse.password` or
`externalClickhouse.existingSecret/existingSecretKey`. Existing Secrets are
recommended for production.

The Job always uses its own `<release>-sentry-clickhouse-prepare`
ServiceAccount. The ServiceAccount is installed as a hook with weight `-1`, so
it exists before the weight `0` prepare Job during the first installation as
well as upgrades. It is independent of the chart-wide dedicated/shared
ServiceAccount mode. Add workload-identity annotations under the prepare
configuration when required:

```yaml
externalClickhouse:
  prepare:
    serviceAccount:
      automountServiceAccountToken: false
      annotations:
        eks.amazonaws.com/role-arn: arn:aws:iam::123456789012:role/sentry-clickhouse-prepare
```

The ServiceAccount uses the `hook-succeeded` delete policy and is removed only
after the complete pre-install/pre-upgrade hook sequence succeeds. It remains
available when the prepare Job fails so the failed hook can be inspected and
is replaced before the next hook run.

The Job is a `pre-install,pre-upgrade` hook. A failed topology, settings or
distributed INSERT check stops the Helm operation. Verify `clusterName`,
`distributedClusterName`, shard and replica counts before enabling it.

When `settings.verify` is enabled without `settings.apply`, the runtime user
must already have the configured settings. Disable the distributed INSERT test
only when the configured ClickHouse account is intentionally not allowed to create and
drop temporary test tables.
