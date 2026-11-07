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

# SQLite-only brokers render no migrate Job.
docs = render({"postgres": postgres}, [broker(name) for name in BROKERS])
assert migrate_jobs(docs) == {}
