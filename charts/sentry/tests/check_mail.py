import json
import os
from pathlib import Path
import subprocess
from unittest.mock import patch

import yaml


chart = Path(__file__).resolve().parents[1]


def check(mail, expected, env=None, as_hook=True):
    result = subprocess.run(
        ["helm", "template", "test", str(chart), "--set", "user.create=false", "-f", "-"],
        input=json.dumps({"mail": mail, "asHook": as_hook}), text=True,
        capture_output=True, check=True,
    )
    config = next(d["data"]["sentry.conf.py"] for d in yaml.safe_load_all(result.stdout)
                  if d and d["kind"] == "ConfigMap" and "sentry.conf.py" in d.get("data", {}))
    config = config[config.index("SENTRY_OPTIONS['mail.backend']"):config.index("SENTRY_OPTIONS['mail.username']")]
    options = {}
    with patch.dict(os.environ, env or {}, clear=True):
        exec(config, {"os": os, "SENTRY_OPTIONS": options})
    actual = {key: value for key, value in options.items() if key != "mail.backend"}
    assert actual == expected, (mail, env, as_hook, actual, expected)


for hook in [True, False]:
    check({}, {}, as_hook=hook)
for tls, ssl in [(False, False), (True, False), (False, True)]:
    check({"backend": "smtp", "useTls": tls, "useSsl": ssl},
          {"mail.use-tls": tls, "mail.use-ssl": ssl})
    check({"useTls": tls, "useSsl": ssl},
          {key: value for key, value in [("mail.use-tls", tls), ("mail.use-ssl", ssl)] if value})
check({}, {"mail.use-tls": False, "mail.use-ssl": False}, {"SENTRY_EMAIL_BACKEND": "smtp"})
check({"backend": "smtp"}, {}, {"SENTRY_EMAIL_BACKEND": "dummy"})
for suffix, key in [("TLS", "mail.use-tls"), ("SSL", "mail.use-ssl")]:
    for raw in ["true", "YES", "1", "false", "0", ""]:
        check({}, {key: raw.lower() in ("true", "1", "yes")}, {"SENTRY_EMAIL_USE_" + suffix: raw})
check({"useTls": True}, {"mail.use-tls": False}, {"SENTRY_EMAIL_USE_TLS": "false"})
check({}, {"mail.use-tls": False, "mail.use-ssl": True},
      {"SENTRY_EMAIL_USE_TLS": "false", "SENTRY_EMAIL_USE_SSL": "true"})
print("Mail setup, TLS/SSL and environment checks passed")
