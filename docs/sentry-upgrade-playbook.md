# Playbook: upgrade the `sentry` chart to a new Sentry release

[getsentry/self-hosted](https://github.com/getsentry/self-hosted) is the reference deployment (Docker Compose). This chart is its Kubernetes translation. An upgrade means porting everything that changed in self-hosted between the current and the target release, then documenting what users must do.

## Rules

- **One PR per self-hosted release.** If the chart is several releases behind, upgrade in order. Each release gets its own `CHANGELOG.md` section.
- **Check [hard stops](https://develop.sentry.dev/self-hosted/releases/#hard-stops).** If one lies between the current and target version, say in `CHANGELOG.md` which chart version users must deploy first.
- **Port only what changed between `FROM` and `TO`.** The chart already differs from compose on purpose in places (consumer group names, Snuba offset flags, broker split). Leave those alone unless the upstream diff touches them.
- **Give every upstream commit a decision:** *Ported*, *N/A* (with the reason), or *Documented* (users must act). Never skip one silently. This list goes in the PR body.
- **Leave alone:** `Chart.yaml` `version`, `charts/sentry/CHANGELOG.md`, and `.release-please-manifest.json`, which release-please owns. Also leave subchart dependencies and infra images: bump those in a separate PR.

## 1. Set up

```sh
FROM=$(yq .appVersion charts/sentry/Chart.yaml)
TO=26.9.0                                   # target self-hosted tag
SH=/tmp/self-hosted
[ -d $SH ] || git clone --filter=blob:none https://github.com/getsentry/self-hosted $SH
git -C $SH fetch --tags --quiet
git fetch origin && git switch -c feat/sentry-$TO origin/develop
```

## 2. Read what changed upstream

```sh
gh release view $TO -R getsentry/self-hosted          # human-written summary, flags breaking changes
git -C $SH log --oneline --no-merges $FROM..$TO
git -C $SH diff --stat $FROM $TO
git -C $SH diff $FROM $TO -- . ':(exclude)*.md' ':(exclude).github' ':(exclude)_integration-test' ':(exclude)_unit-test' ':(exclude)uv.lock' ':(exclude)pyproject.toml'
```

If a commit's intent is unclear, read its PR (the number is in the subject): `gh pr view <n> -R getsentry/self-hosted`. A PR description often explains the change (for example, a consumer moved into a taskworker task) and tells you which chart change follows from it.

Also read the breaking changes in the component releases: `gh release view $TO -R getsentry/<repo>` for `snuba`, `relay` and `symbolicator`. Snuba's commit list (`gh api repos/getsentry/snuba/compare/$FROM...$TO`) shows ClickHouse version and settings changes that self-hosted never touches.

### Image changes the diff doesn't show

The chart overrides image entrypoints and runs probes inside the containers, so a change to an image's user or shell can break pods without any matching self-hosted change. Compare the image configs:

```sh
for img in sentry snuba relay symbolicator vroom taskbroker uptime-checker launchpad; do for v in $FROM $TO; do
  echo "$img $v $(docker buildx imagetools inspect ghcr.io/getsentry/$img:$v --format '{{json .Image}}' \
    | yq -p json '(.config // .["linux/amd64"].config) | (.User // "root") + "  " + ((.Entrypoint // []) | join(" "))')"
done; done
docker run --rm --entrypoint python3 ghcr.io/getsentry/snuba:$TO -c 'import shutil; print([shutil.which(b) for b in ("sh", "bash")])'
```

- **User changed** (26.10.0: the sentry image went from root to uid 999): check that PVC mounts stay writable. `sentry.podSecurityContext` sets the `fsGroup`.
- **Shell gone** (26.10.0: the snuba image): every `sh -c`, `test` or `stat` that runs in that image fails. That includes the exec probes in `templates/_helper.tpl`, which now use `python3`.

## 3. Map each change to the chart

All paths are under `charts/sentry/`.

| self-hosted | chart |
|---|---|
| `.env` `*_IMAGE` tags | `Chart.yaml` `appVersion`. Every getsentry image (sentry, snuba, relay, symbolicator, vroom, taskbroker, uptime-checker, launchpad) defaults to it in `templates/_helper.tpl`. |
| `docker-compose.yml`: Sentry/Snuba service added, removed, or `command` changed | `templates/sentry/**`, `templates/snuba/deployment-*.yaml`, the matching `values.yaml` block (`sentry.<camelCase>` / `snuba.<camelCase>`), and the `README.md` table rows. See [§5](#5-add-or-remove-a-component). |
| `docker-compose.yml` `profiles:` | The `{{- if has "feature-complete" .Values.profiles }}` guard in the template. |
| `x-sentry-defaults` / `x-snuba-defaults` env | `sentry.env` / `sentry.snuba.env` in `templates/_helper.tpl` |
| vroom / uptime-checker / launchpad env | `vroom.env` / `uptimeChecker.env` / `launchpadTaskWorker.env` in `templates/_helper.tpl` |
| `sentry/sentry.conf.example.py` | The `sentry.conf.py: \|-` block in `templates/sentry/_helper-sentry.tpl`. Feature flags live there; user toggles live in `values.yaml` `sentry.features`. |
| `sentry/config.example.yml` | The `config.yml: \|-` block in the same file |
| `relay/config.example.yml` | `templates/relay/_helper-sentry-relay.tpl` |
| `symbolicator/config.example.yml` | `templates/symbolicator/_helper-symbolicator.tpl` |
| `taskbroker/config.yml` | `values.yaml` `sentry.taskBroker.brokers[]` (`kafkaTopics`, `kafkaDeadletterTopic`, …) and `templates/sentry/taskbroker/_helper-taskbroker.tpl`. Self-hosted runs one broker; the chart has `default`/`ingest`/`long`/`products`, so put each topic on the broker whose existing topics are most alike. |
| `install/set-up-and-migrate-database.sh` | `templates/hooks/sentry-db-init.job.yaml`, `templates/hooks/user-create.yaml` |
| `install/bootstrap-snuba.sh` | `templates/hooks/snuba-db-init.job.yaml`, `templates/hooks/snuba-migrate.job.yaml` |
| Kafka topics (`sentry upgrade --create-kafka-topics`, Snuba bootstrap) | `values.yaml` `kafka.provisioning.topics`. See [§4](#4-kafka-topics). |
| ClickHouse `BASE_IMAGE` in compose / `clickhouse/Dockerfile` | `ci/services/clickhouse/clickhouse-external.yaml` image (keep it equal to upstream). Users run their own ClickHouse, so state the new minimum version in `CHANGELOG.md`. |
| `clickhouse/config.xml` | Usually N/A. Document it if the setting is required for Snuba to work. |
| `nginx.conf` | `templates/routing/nginx-config.yaml`. Document any timeout or size change that ingress users must copy into annotations. |
| `cron/`, `sentry-cleanup` | `templates/sentry/cleanup/` |
| `geoip/`, `install/geoip.sh` | `templates/geoip/` |
| `install/upgrade-*.sh`, `install/migrate-*.sh` | No template change. Document the change if users must act, for example a minimum Postgres version. |
| Infra images and config (postgres, valkey/redis, kafka, memcached, nginx, pgbouncer, seaweedfs) | N/A: the chart uses subcharts or external services. List them in the CHANGELOG "does not apply" line. |
| `optional-modifications/`, tests, CI, docs, Python tooling | N/A |

## 4. Kafka topics

Diff the upstream topic enums between the two tags. Don't diff them against the chart: the chart's list also holds taskworker topics and legacy topics.

```sh
topics() { for f in getsentry/sentry:src/sentry/conf/types/kafka_definition.py getsentry/snuba:snuba/utils/streams/topics.py; do
  gh api "repos/${f%%:*}/contents/${f#*:}?ref=$1" --jq .content | base64 -d \
    | sed -n '/^class Topic(Enum)/,/^[^ ]/p' | grep -oE '^ +[A-Z0-9_]+ = "[^"]+"' | cut -d'"' -f2
done | sort -u; }
comm -3 <(topics $FROM) <(topics $TO)   # no indent = removed, tab-indented = added
```

Then apply the result:

- **Added topics:** add them to `kafka.provisioning.topics`.
- **Removed topics:** drop them only if `grep -rn <topic> charts/sentry` finds no other use. Removing a topic from the list does not delete it from Kafka.
- **taskbroker topics:** apply any new topic names from `taskbroker/config.yml` (topics, retry, DLQ) as well.

## 5. Add or remove a component

**Removed upstream:**

- Delete its templates (deployment, serviceaccount, hpa) and its `values.yaml` block.
- Delete its `README.md` rows.
- Remove every reference: `grep -rn <valuesKey> charts/sentry` covers `_helper.tpl`, other templates, and `ci/*.yaml`.
- In `CHANGELOG.md`, tell users to remove their overrides for that key.

**Added upstream:**

- Copy the nearest sibling: `templates/sentry/ingest/feedback/` for a Sentry consumer, or `templates/snuba/deployment-snuba-replays-consumer.yaml` for a Snuba consumer. Copy the sibling's `values.yaml` block too.
- Translate the compose `command` flags into values (`autoOffsetReset`, `noStrictOffsetReset`, `maxPollIntervalMs`, `maxBatchTimeMs`, …) the same way the sibling does.
- Add the `feature-complete` guard if the compose service has `profiles: [feature-complete]`.
- Add the `README.md` rows.

## 6. Bump and document

1. In `Chart.yaml`, set `appVersion: $TO`.
2. Add a section at the top of the root `CHANGELOG.md`, in the existing format:

   ```md
   ## Upgrading to Chart <next>

   Chart `<next>` targets [Sentry $TO](https://github.com/getsentry/self-hosted/releases/tag/$TO).

   - <values added / removed / renamed, changed defaults>
   - <required user actions: min ClickHouse/Postgres version, topics to create on external Kafka, hard stops>
   - Self-hosted also <…>. Those do not apply to this chart (<reason>).
   ```

   To get `<next>`, take the `charts/sentry` version in `.release-please-manifest.json` and bump the minor for `feat:` or the major for `feat!:`. Recheck it before merge, because another release may land first.

   It is **breaking** (`feat!:`) when an existing values key is renamed, becomes required, or makes the render fail, or when users must act before upgrading. It is not breaking if removed components leave overrides that are silently ignored.

## 7. Validate

```sh
[ -d charts/sentry/charts ] || helm dependency build charts/sentry
helm lint charts/sentry
for p in feature-complete errors-only; do
  helm template s charts/sentry --set user.password=x --set "profiles={$p}" > /tmp/render-$p.yaml || echo "FAIL $p"
done
helm template s charts/sentry -f charts/sentry/ci/kind-values.yaml > /dev/null
```

Then run a parity check: list the compose commands at `TO` next to the chart's rendered commands.

```sh
git -C $SH show $TO:docker-compose.yml \
  | yq -r '.services | to_entries[] | select(.value.command) | .key + "  " + (.value.command | (select(tag=="!!seq") | join(" ")) // .)'
yq -r 'select(.kind=="Deployment" or .kind=="StatefulSet" or .kind=="CronJob")
  | (.spec.template.spec // .spec.jobTemplate.spec.template.spec) as $p
  | .metadata.name + "  " + ((($p.containers[0].command // []) + ($p.containers[0].args // [])) | join(" "))' \
  /tmp/render-feature-complete.yaml | grep -v '^---'
```

Also check that every consumer the chart still runs exists in Sentry at `TO`. A consumer removed from Sentry makes its Deployment crashloop:

```sh
gh api "repos/getsentry/sentry/contents/src/sentry/consumers/__init__.py?ref=$TO" --jq .content | base64 -d \
  | grep -oE '^    "[a-z0-9-]+": \{' | cut -d'"' -f2 | sort > /tmp/sentry-consumers
grep -A1 '"consumer"' /tmp/render-feature-complete.yaml | grep -oE '"[a-z0-9-]+"' | tr -d '"' | grep -v '^consumer$' | sort -u \
  | grep -vxFf /tmp/sentry-consumers   # prints consumers that no longer exist
```

Match the two lists by consumer name (`run consumer <name>`) or Snuba `--storage`/`--entity`, not by workload name. Every Sentry/Snuba service in compose needs a chart workload, and the reverse, apart from infra and components that are disabled by default (profiling, for example).

CI `ct install` deploys `ci/kind-values.yaml`, which uses the `errors-only` profile. `feature-complete`-only components are therefore only render-checked. Say so in the PR.

## 8. Open the PR

- Title: `feat: upgrade to sentry v$TO`, or `feat!: …` if the upgrade is breaking. The conventional-commit check enforces the format.
- Body: link the self-hosted release, then add a table with one row per upstream commit: `commit | decision (Ported / N/A / Documented) | chart change or reason`.
