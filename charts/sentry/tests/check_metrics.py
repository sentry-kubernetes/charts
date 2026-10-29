import json
from pathlib import Path
import subprocess

import yaml


chart = Path(__file__).resolve().parents[1]


def render(metrics, global_values=None):
    values = {"metrics": {"enabled": True, **metrics}, "global": global_values or {}}
    return subprocess.run(
        ["helm", "template", "test", str(chart), "--set", "user.create=false",
         "--show-only", "templates/sentry/metrics/deployment-metrics.yaml", "-f", "-"],
        input=json.dumps(values), text=True, capture_output=True,
    )


result = render({})
assert result.returncode == 0, result.stderr
pod = yaml.safe_load(result.stdout)["spec"]["template"]["spec"]
default_args = ["--statsd.listen-udp=:9125", "--web.listen-address=:9102"]
assert pod["containers"][0]["args"] == default_args
assert "volumes" not in pod and "volumeMounts" not in pod["containers"][0]

volumes = [{"name": name, "emptyDir": {}} for name in ["base", "extra", "global"]]
mounts = [{"name": v["name"], "mountPath": "/" + v["name"]} for v in volumes]
args = ["--log.level=debug", "--statsd.parse-dogstatsd-tags=false"]
result = render(
    {"extraArgs": args, "volumes": volumes[:1], "extraVolumes": volumes[1:2],
     "volumeMounts": mounts[:1], "extraVolumeMounts": mounts[1:2]},
    {"volumes": volumes[2:], "volumeMounts": mounts[2:]},
)
assert result.returncode == 0, result.stderr
pod = yaml.safe_load(result.stdout)["spec"]["template"]["spec"]
assert pod["containers"][0]["args"] == default_args + args
assert pod["volumes"] == volumes
assert pod["containers"][0]["volumeMounts"] == mounts

for invalid in [{"statsd.parse-dogstatsd-tags": False}, [False], "--log.level=debug"]:
    result = render({"extraArgs": invalid})
    assert result.returncode != 0
    assert "metrics.extraArgs must be a list of strings" in result.stderr

print("Metrics argument and volume checks passed")
