import ast
from enum import Enum
import json
from pathlib import Path
import subprocess

import yaml


chart = Path(__file__).resolve().parents[1]
Topic = Enum("Topic", {"EVENTS": "events", "SUBSCRIPTIONS": "events-subscription-results"})
original = {"events": "ingest", "events-subscription-results": "default", "custom": "other"}
for prefix in ["", "sentry-", "tenant.a-"]:
    result = subprocess.run(
        ["helm", "template", "test", str(chart), "--set", "user.create=false", "-f", "-"],
        input=json.dumps({"kafkaTopicOverrides": {"prefix": prefix}}), text=True,
        capture_output=True, check=True,
    )
    config = next(d["data"]["sentry.conf.py"] for d in yaml.safe_load_all(result.stdout)
                  if d and d["kind"] == "ConfigMap" and "sentry.conf.py" in d.get("data", {}))
    namespace = {"Topic": Topic, "KAFKA_TOPIC_OVERRIDES": {}, "KAFKA_TOPIC_TO_CLUSTER": original.copy()}
    if prefix:
        block = config[config.index("SENTRY_CHARTS_KAFKA_TOPIC_PREFIX ="):config.index('KAFKA_CLUSTERS["default"] =')]
        tree = ast.parse(block)
        tree.body = [node for node in tree.body if not isinstance(node, ast.ImportFrom)]
        exec(compile(tree, "sentry.conf.py", "exec"), namespace)
    else:
        assert "SENTRY_CHARTS_KAFKA_TOPIC_PREFIX =" not in config
    for topic in Topic:
        physical = namespace["KAFKA_TOPIC_OVERRIDES"].get(topic.value, topic.value)
        assert namespace["KAFKA_TOPIC_TO_CLUSTER"][physical] == original[topic.value]
    assert all(namespace["KAFKA_TOPIC_TO_CLUSTER"][key] == value for key, value in original.items())
print("Kafka prefix cluster-mapping checks passed")
