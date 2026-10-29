import base64
from pathlib import Path
import subprocess
import time
import uuid

import yaml


chart = Path(__file__).resolve().parents[1]
rendered = subprocess.run(
    ["helm", "template", "test", str(chart), "--set", "user.create=false",
     "--set", "pgbouncer.enabled=true", "--set", "postgresql.enabled=false",
     "--set", "externalPostgresql.host=postgres", "--set", "externalPostgresql.username=app",
     "--set", "externalPostgresql.database=app", "--set", "externalPostgresql.password=placeholder"],
    text=True, capture_output=True, check=True,
)
docs = [d for d in yaml.safe_load_all(rendered.stdout) if d]
deployment = next(d for d in docs if d["kind"] == "Deployment" and d["metadata"]["name"].endswith("-pgbouncer"))
container = deployment["spec"]["template"]["spec"]["containers"][0]
env = {}
for source in container.get("envFrom", []):
    secret = next(d for d in docs if d["kind"] == "Secret" and d["metadata"]["name"] == source["secretRef"]["name"])
    env.update({key: base64.b64decode(value).decode() for key, value in secret["data"].items()})
env.update({e["name"]: e["value"] for e in container["env"] if "value" in e})
assert env["AUTH_TYPE"] == "scram-sha-256"
blocked = subprocess.run([*rendered.args, "--set", "pgbouncer.authType=md5"], text=True, capture_output=True)
assert blocked.returncode != 0 and "pgbouncer.authType" in blocked.stderr
for modern, legacy in [("DB_HOST", "POSTGRESQL_HOST"), ("DB_PORT", "POSTGRESQL_PORT"),
                       ("DB_NAME", "PGBOUNCER_DATABASE"), ("DB_USER", "POSTGRESQL_USERNAME"),
                       ("DB_PASSWORD", "POSTGRESQL_PASSWORD")]:
    assert env[modern] == env[legacy]

prefix = "sentry-pgbouncer-check-" + uuid.uuid4().hex[:8]
network, postgres, bouncer = [prefix + suffix for suffix in ["-net", "-postgres", "-pool"]]


def docker(*args, **kwargs):
    return subprocess.run(["docker", *args], text=True, capture_output=True, **kwargs)


def query(password):
    return docker("exec", "-e", "PGPASSWORD=" + password, "-e", "PGCONNECT_TIMEOUT=3", postgres,
                  "psql", "-w", "-h", bouncer, "-p", env["LISTEN_PORT"], "-U", "app",
                  "-d", "app", "-Atc", "select current_user, current_database()", timeout=15)


def check_backend(backend):
    docker("run", "-d", "--name", postgres, "--network", network, "--network-alias", "postgres",
           "-e", "POSTGRES_PASSWORD=check-admin", "-e", "POSTGRES_HOST_AUTH_METHOD=" + backend,
           "postgres:16-alpine", "-c", "password_encryption=" + backend, check=True)
    for _ in range(60):
        if docker("exec", postgres, "pg_isready", "-U", "postgres").returncode == 0:
            break
        time.sleep(1)
    else:
        raise AssertionError("PostgreSQL did not start")
    docker("exec", "-i", postgres, "psql", "-U", "postgres", "-v", "ON_ERROR_STOP=1",
           input="CREATE ROLE app LOGIN; CREATE DATABASE app OWNER app;", check=True)
    for password in ["ordinary", "colon:password", "at@password", "both:p@ss/word?= x"]:
        docker("exec", "-i", postgres, "psql", "-U", "postgres", "-v", "ON_ERROR_STOP=1",
               input="ALTER ROLE app PASSWORD '" + password + "';", check=True)
        pattern = "SCRAM-SHA-256$%" if backend == "scram-sha-256" else "md5%"
        verifier = docker("exec", postgres, "psql", "-U", "postgres", "-Atc",
                          "SELECT rolpassword LIKE '" + pattern + "' FROM pg_authid WHERE rolname='app'", check=True)
        assert verifier.stdout.strip() == "t"
        docker("rm", "-f", bouncer)
        args = ["run", "-d", "--name", bouncer, "--network", network]
        for name, value in env.items():
            args += ["-e", name + "=" + (password if name in ["DB_PASSWORD", "POSTGRESQL_PASSWORD"] else value)]
        docker(*args, container["image"], check=True)
        for _ in range(30):
            result = query(password)
            if result.returncode == 0:
                break
            time.sleep(1)
        assert result.returncode == 0, result.stderr
        assert result.stdout.strip() == "app|app"
        assert query("wrong-password").returncode != 0
        assert query("").returncode != 0
        print(backend + ": connection and rejected missing/wrong passwords passed", flush=True)
    docker("rm", "-fv", bouncer, postgres, check=True)


try:
    docker("network", "create", network, check=True)
    for backend in ["scram-sha-256", "md5"]:
        check_backend(backend)
finally:
    for name in [bouncer, postgres]:
        docker("rm", "-fv", name)
    docker("network", "rm", network)
