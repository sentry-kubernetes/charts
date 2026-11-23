from pathlib import Path
import json
import subprocess

import yaml


chart = Path(__file__).resolve().parents[1]
BROKERS = ["default", "ingest", "long"]


def render(store, brokers):
    values = {
        "user": {"create": False},
        "sentry": {"taskBroker": {"store": store, "brokers": brokers}},
    }
    rendered = subprocess.run(
        ["helm", "template", "test", str(chart), "-f", "-"],
        input=json.dumps(values), text=True, capture_output=True, check=True,
    )
    return [d for d in yaml.safe_load_all(rendered.stdout) if d]


def broker(name, **extra):
    return {
        "name": name,
        "kafkaDeadletterTopic": f"taskworker-{name}-dlq",
        "kafkaRetryTopic": f"taskworker-{name}",
        "kafkaTopics": {f"taskworker-{name}": {"cluster": "default", "consumerGroup": f"taskworker-{name}"}},
        **extra,
    }


def broker_config(docs, name):
    cm = next(d for d in docs if d["kind"] == "ConfigMap" and d["metadata"]["name"] == f"test-sentry-taskbroker-{name}-config")
    return yaml.safe_load(cm["data"]["config.yml"])


def migrate_jobs(docs):
    jobs = [d for d in docs if d["kind"] == "Job" and d["metadata"]["labels"].get("role") == "taskbroker-migrate"]
    configs = {
        d["metadata"]["name"]: yaml.safe_load(d["data"]["config.yml"])
        for d in docs if d["kind"] == "ConfigMap" and d["metadata"]["labels"].get("role") == "taskbroker-migrate"
    }
    return {j["metadata"]["name"]: configs[j["metadata"]["name"]]["store"]["pg"]["database_name"] for j in jobs}


def env(docs, kind, name):
    obj = next(d for d in docs if d["kind"] == kind and d["metadata"]["name"] == name)
    return {e["name"]: e for e in obj["spec"]["template"]["spec"]["containers"][0]["env"]}


postgres = {"host": "postgres-rw", "existingSecret": "pg", "existingSecretKey": "password"}
pg = {"adapter": "postgres"}

# Brokers without their own store.postgres inherit the global database; one migrate Job.
docs = render({"postgres": {**postgres, "database": "taskbroker"}},
              [broker("default", store=pg), broker("ingest", store=pg), broker("long")])
assert broker_config(docs, "default")["store"]["pg"]["database_name"] == "taskbroker"
assert broker_config(docs, "ingest")["store"]["pg"]["database_name"] == "taskbroker"
assert "store" not in broker_config(docs, "long")
assert migrate_jobs(docs) == {"test-sentry-taskbroker-migrate-default": "taskbroker"}

# Per-broker database overrides the global one; each distinct database gets its own migrate Job.
docs = render({"postgres": {**postgres, "database": "taskbroker"}},
              [broker("default", store={**pg, "postgres": {"database": "taskbroker_default"}}),
               broker("ingest", store={**pg, "postgres": {"database": "taskbroker_ingest"}}),
               broker("long", store=pg)])
assert broker_config(docs, "default")["store"]["pg"]["database_name"] == "taskbroker_default"
assert broker_config(docs, "ingest")["store"]["pg"]["database_name"] == "taskbroker_ingest"
assert broker_config(docs, "long")["store"]["pg"]["database_name"] == "taskbroker"
for name in BROKERS:
    assert broker_config(docs, name)["store"]["pg"]["host"] == "postgres-rw"
assert migrate_jobs(docs) == {
    "test-sentry-taskbroker-migrate-default": "taskbroker_default",
    "test-sentry-taskbroker-migrate-ingest": "taskbroker_ingest",
    "test-sentry-taskbroker-migrate-long": "taskbroker",
}

# A per-broker secret applies to that broker and its migrate Job only.
docs = render({"postgres": postgres},
              [broker("default", store={**pg, "postgres": {"database": "taskbroker_default", "existingSecret": "pg-default"}}),
               broker("ingest", store=pg)])
assert env(docs, "StatefulSet", "test-sentry-taskbroker-default")["TASKBROKER_STORE__PG__PASSWORD"]["valueFrom"]["secretKeyRef"]["name"] == "pg-default"
assert env(docs, "StatefulSet", "test-sentry-taskbroker-ingest")["TASKBROKER_STORE__PG__PASSWORD"]["valueFrom"]["secretKeyRef"]["name"] == "pg"
assert env(docs, "Job", "test-sentry-taskbroker-migrate-default")["TASKBROKER_STORE__PG__PASSWORD"]["valueFrom"]["secretKeyRef"]["name"] == "pg-default"

# Broker credentials replace the global ones as a set: a broker secret beats a global
# password, and global DDL credentials are not inherited.
docs = render({"postgres": {"host": "postgres-rw", "user": "tb", "password": "global",
                            "ddlUser": "tb_ddl", "ddlExistingSecret": "pg-ddl"}},
              [broker("default", store={**pg, "postgres": {"database": "taskbroker_default", "user": "tb_default",
                                                           "existingSecret": "pg-default"}}),
               broker("ingest", store=pg)])
for kind, name in [("StatefulSet", "test-sentry-taskbroker-default"), ("Job", "test-sentry-taskbroker-migrate-default")]:
    e = env(docs, kind, name)
    assert e["TASKBROKER_STORE__PG__PASSWORD"]["valueFrom"]["secretKeyRef"] == {"name": "pg-default", "key": "postgresql-password"}
    assert e["TASKBROKER_STORE__PG__DDL_PASSWORD"]["valueFrom"]["secretKeyRef"] == {"name": "pg-default", "key": "postgresql-password"}
assert broker_config(docs, "default")["store"]["pg"]["username"] == "tb_default"
assert broker_config(docs, "default")["store"]["pg"]["ddl_username"] == "tb_default"
assert broker_config(docs, "default")["store"]["pg"]["host"] == "postgres-rw"
e = env(docs, "StatefulSet", "test-sentry-taskbroker-ingest")
assert e["TASKBROKER_STORE__PG__PASSWORD"]["value"] == "global"
assert e["TASKBROKER_STORE__PG__DDL_PASSWORD"]["valueFrom"]["secretKeyRef"]["name"] == "pg-ddl"
assert broker_config(docs, "ingest")["store"]["pg"]["ddl_username"] == "tb_ddl"

# Migrate Job names stay within 63 characters and unique.
long_a, long_b = "a" * 40 + "-one", "a" * 40 + "-two"
docs = render({"postgres": postgres},
              [broker(long_a, store={**pg, "postgres": {"database": "one"}}),
               broker(long_b, store={**pg, "postgres": {"database": "two"}})])
names = list(migrate_jobs(docs))
assert len(names) == 2 and len(set(names)) == 2
assert all(len(n) <= 63 for n in names), names

# SQLite-only brokers render no migrate Job.
docs = render({"postgres": postgres}, [broker(name) for name in BROKERS])
assert migrate_jobs(docs) == {}
