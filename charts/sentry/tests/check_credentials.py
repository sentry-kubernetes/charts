import base64
import copy
import json
from pathlib import Path
import subprocess

import yaml


chart = Path(__file__).resolve().parents[1]
base = {"postgresql": {"enabled": False}, "externalPostgresql": {"host": "postgres", "password": 12345},
        "mail": {"password": 23456}, "user": {"password": 34567}, "pgbouncer": {"enabled": True}}


def render(values):
    result = subprocess.run(["helm", "template", "test", str(chart), "-f", "-"],
                            input=json.dumps(values), text=True, capture_output=True, check=True)
    return {d["metadata"]["name"]: d for d in yaml.safe_load_all(result.stdout)
            if d and d["kind"] in ["Secret", "Deployment", "Job"]}


def find(docs, suffix):
    return next(d for name, d in docs.items() if name.endswith(suffix))


def env(doc):
    return {e["name"]: e for e in doc["spec"]["template"]["spec"]["containers"][0]["env"]}


for argo in [False, True]:
    for pre in [False, True]:
        values = copy.deepcopy(base)
        values.update({"useArgoCdCompatibleAnnotations": argo, "hooks": {"preUpgrade": pre}})
        docs = render(values)
        secret = find(docs, "-hooks-env")
        decoded = {k: base64.b64decode(v).decode() for k, v in secret["data"].items()}
        assert decoded == {"POSTGRES_PASSWORD": "12345", "SENTRY_EMAIL_PASSWORD": "23456", "ADMIN_PASSWORD": "34567"}
        annotations = secret["metadata"]["annotations"]
        if argo:
            assert "helm.sh/hook" not in annotations and "argocd.argoproj.io/hook" not in annotations
            assert annotations["argocd.argoproj.io/sync-wave"] == "-5"
        else:
            assert annotations["helm.sh/hook"] == "post-install," + ("pre-upgrade" if pre else "post-upgrade")
            assert set(annotations["helm.sh/hook-delete-policy"].split(",")) == {"before-hook-creation", "hook-succeeded"}
        for suffix in ["-db-init", "-user-create"]:
            job = find(docs, suffix)
            for key in ["POSTGRES_PASSWORD", "SENTRY_EMAIL_PASSWORD"]:
                ref = env(job)[key]["valueFrom"]["secretKeyRef"]
                assert ref == {"name": secret["metadata"]["name"], "key": key}
            if not argo:
                assert job["metadata"]["annotations"]["helm.sh/hook"] == annotations["helm.sh/hook"]
                assert int(annotations["helm.sh/hook-weight"]) < int(job["metadata"]["annotations"]["helm.sh/hook-weight"])
        assert "ADMIN_PASSWORD" not in env(find(docs, "-db-init"))
        hook_sources = find(docs, "-db-init")["spec"]["template"]["spec"]["containers"][0]["envFrom"]
        assert all(e["secretRef"]["name"].endswith("-sentry-env") for e in hook_sources)
        fleet_sources = find(docs, "-web")["spec"]["template"]["spec"]["containers"][0]["envFrom"]
        assert all(not e["secretRef"].get("optional", False) for e in fleet_sources)
        assert env(find(docs, "-user-create"))["ADMIN_PASSWORD"]["valueFrom"]["secretKeyRef"]["key"] == "ADMIN_PASSWORD"
        pod = find(docs, "-pgbouncer")["spec"]["template"]["spec"]
        assert all(not e["secretRef"].get("optional", False) for e in pod["containers"][0]["envFrom"])

values = copy.deepcopy(base)
values["user"] = {"create": False}
assert "ADMIN_PASSWORD" not in find(render(values), "-hooks-env")["data"]
values["hooks"] = {"enabled": False}
assert not any(name.endswith("-hooks-env") for name in render(values))
values = copy.deepcopy(base)
values["externalPostgresql"] = {"host": "postgres", "existingSecret": "pg", "existingSecretKeys": {"password": "pg-key"}}
values["mail"] = {"existingSecret": "smtp"}
values["user"] = {"existingSecret": "admin", "existingSecretKey": "admin-key"}
docs = render(values)
assert not any(name.endswith("-hooks-env") for name in docs)
assert env(find(docs, "-user-create"))["ADMIN_PASSWORD"]["valueFrom"]["secretKeyRef"] == {"name": "admin", "key": "admin-key"}
assert env(find(docs, "-db-init"))["POSTGRES_PASSWORD"]["valueFrom"]["secretKeyRef"]["key"] == "pg-key"
first = find(render(base), "-web")["spec"]["template"]["metadata"]["annotations"]["checksum/config.yaml"]
values = copy.deepcopy(base)
values["externalPostgresql"]["password"] = "rotated"
second = find(render(values), "-web")["spec"]["template"]["metadata"]["annotations"]["checksum/config.yaml"]
assert first != second
print("Credential precedence, hook phases, required references and rotation checks passed")
