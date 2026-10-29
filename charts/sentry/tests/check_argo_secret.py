import json
from pathlib import Path
import subprocess

import yaml


chart = Path(__file__).resolve().parents[1]
for argo in [False, True]:
    for external in [False, True]:
        values = {"user": {"create": False}, "useArgoCdCompatibleAnnotations": argo}
        if external:
            values["sentry"] = {"existingSecret": "stable-key"}
        result = subprocess.run(["helm", "template", "test", str(chart), "-f", "-"],
                                input=json.dumps(values), text=True, capture_output=True, check=True)
        secrets = [d for d in yaml.safe_load_all(result.stdout)
                   if d and d["kind"] == "Secret" and d["metadata"]["name"].endswith("-sentry-secret")]
        assert len(secrets) == (0 if external else 1)
        if not external:
            annotations = secrets[0]["metadata"]["annotations"]
            if argo:
                assert annotations == {"argocd.argoproj.io/sync-wave": "-1"}
            else:
                assert annotations["helm.sh/hook"] == "pre-install"
print("ArgoCD secret compatibility and Helm lifecycle checks passed")
