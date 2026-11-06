from pathlib import Path
import subprocess

import yaml


chart = Path(__file__).resolve().parents[1]
base = ["helm", "template", "test", str(chart), "--set", "user.create=false"]


def render(*args):
    result = subprocess.run([*base, *args], text=True, capture_output=True, check=True)
    return [d for d in yaml.safe_load_all(result.stdout) if d]


def find(docs, kind, suffix):
    return next(d for d in docs if d["kind"] == kind and d["metadata"]["name"].endswith(suffix))


def rejected(*args):
    result = subprocess.run([*base, *args], text=True, capture_output=True)
    return result.returncode != 0 and "validate-kafka-image.yaml" in result.stderr


docs = render()

# Broker: apache/kafka started directly, data on the bitnami path, bitnami's uid/gid kept.
spec = find(docs, "StatefulSet", "-kafka-controller")["spec"]["template"]["spec"]
containers = {c["name"]: c for c in spec["initContainers"] + spec["containers"]}
kafka, fmt = containers["kafka"], containers["kafka-kraft-format"]
assert kafka["image"].endswith("apache/kafka:3.7.1"), kafka["image"]
assert kafka["command"] == ["/opt/kafka/bin/kafka-server-start.sh"]
assert fmt["image"] == kafka["image"] and fmt["imagePullPolicy"] == kafka["imagePullPolicy"]
# apache/kafka declares VOLUME /var/lib/kafka/data; mounting above it gets shadowed by the runtime.
for c in (kafka, fmt, containers["kafka-init"]):
    mounts = {m["name"]: m["mountPath"] for m in c["volumeMounts"]}
    assert mounts["data"] == "/bitnami/kafka", (c["name"], mounts)
# Existing PVCs hold 1001:1001 / 644 data; uid 1000 cannot open it where fsGroup is not applied.
assert spec["securityContext"]["fsGroup"] == 1001
for c in containers.values():
    assert c["securityContext"]["runAsUser"] == 1001, c["name"]
    assert c["securityContext"]["runAsGroup"] == 1001, c["name"]
config = find(docs, "ConfigMap", "-kafka-controller-configuration")["data"]["server.properties"]
assert "log.dir=/bitnami/kafka/data" in config

# Provisioning: no bitnami-only binaries or scripts.
job = find(docs, "Job", "-kafka-provisioning")["spec"]["template"]["spec"]
waits = [c for c in job["initContainers"] if c["name"] == "wait-for-available-kafka"]
assert len(waits) == 1 and "wait-for-port" not in str(waits[0])
script = "\n".join(job["containers"][0]["args"])
assert "/opt/kafka/bin/kafka-topics.sh" in script
assert "/opt/bitnami" not in script and "libkafka.sh" not in script
assert "--topic snuba-llm-proxy-cost" in script

# kraft.existingClusterIdSecret reaches the format init container, not only the broker.
spec = find(render("--set", "kafka.kraft.existingClusterIdSecret=my-id"), "StatefulSet", "-kafka-controller")["spec"]["template"]["spec"]
refs = [e["valueFrom"]["secretKeyRef"]["name"] for c in spec["initContainers"] + spec["containers"]
        for e in c.get("env", []) if e["name"] == "KAFKA_KRAFT_CLUSTER_ID"]
assert refs == ["my-id", "my-id"], refs

# Unsupported settings fail rendering while apache/kafka is in use, and only then.
assert rejected("--set", "kafka.listeners.client.protocol=SASL_PLAINTEXT")
assert rejected("--set", "kafka.listeners.interbroker.protocol=SSL", "--set", "kafka.tls.existingSecret=certs")
assert rejected("--set", "kafka.broker.replicaCount=1")
render("--set", "kafka.image.repository=bitnamilegacy/kafka", "--set", "kafka.listeners.client.protocol=SASL_PLAINTEXT")
render("--set", "kafka.enabled=false", "--set", "externalKafka.host=kafka", "--set", "externalKafka.port=9092",
       "--set", "kafka.listeners.client.protocol=SASL_PLAINTEXT")
print("Kafka image checks passed")
