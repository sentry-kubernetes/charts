import json
from pathlib import Path
import subprocess

import yaml


chart = Path(__file__).resolve().parents[1]


def claim(access_modes):
    values = {"symbolicator": {"enabled": True, "api": {
        "usedeployment": False, "persistence": {"accessModes": access_modes}}}}
    result = subprocess.run(
        ["helm", "template", "test", str(chart), "--set", "user.create=false",
         "--show-only", "templates/symbolicator/statefulset-symbolicator.yaml", "-f", "-"],
        input=json.dumps(values), text=True, capture_output=True, check=True,
    )
    return yaml.safe_load(result.stdout)["spec"]["volumeClaimTemplates"][0]["spec"]


for modes in [["ReadWriteOnce"], ["ReadWriteOnce", "ReadOnlyMany"]]:
    assert claim(modes)["accessModes"] == modes, (modes, claim(modes))

print("Symbolicator StatefulSet persistence checks passed")
