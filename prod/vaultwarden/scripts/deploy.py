"""Update Compose using the native SSH agent, without putting OAuth secrets in state."""
import base64
import json
import os
import subprocess

from runtime import credentials


REMOTE_UPDATE = r'''
import base64, json, os, pathlib, subprocess, sys
os.umask(0o077)
settings = json.load(sys.stdin)
env_path = pathlib.Path('/srv/vaultwarden/secrets/vaultwarden.env')
lines = env_path.read_text().splitlines()
credentials = settings.get('credentials')
if settings.get('admin_token'):
    from argon2 import PasswordHasher
    from argon2.exceptions import VerificationError, InvalidHash
    hasher = PasswordHasher(time_cost=3, memory_cost=65536, parallelism=4)
    existing = next((line.split('=', 1)[1].strip("'") for line in lines if line.startswith('ADMIN_TOKEN=')), '')
    try:
        hasher.verify(existing, settings['admin_token'])
    except (VerificationError, InvalidHash):
        lines = [line for line in lines if not line.startswith('ADMIN_TOKEN=')]
        lines.append("ADMIN_TOKEN='" + hasher.hash(settings['admin_token']) + "'")
        credentials = credentials or {}
if credentials:
    lines = [line for line in lines if not line.startswith(('SSO_CLIENT_ID=', 'SSO_CLIENT_SECRET='))]
    for key, value in credentials.items():
        if any(char in value for char in "\r\n'"):
            raise SystemExit('OAuth credential contains invalid environment-file characters')
        lines.append(f"{key}='{value}'")
if credentials is not None:
    env_path.write_text('\n'.join(lines) + '\n')
    env_path.chmod(0o600)
if settings['sso_enabled']:
    if not all(any(line.startswith(key + '=') for line in lines) for key in ('SSO_CLIENT_ID', 'SSO_CLIENT_SECRET')):
        raise SystemExit('Install the Google OAuth credentials before enabling SSO')
config = pathlib.Path('/srv/vaultwarden/data/config.json')
if config.exists():
    raise SystemExit('Admin configuration overrides exist; review them before automated deployment')
compose_path = pathlib.Path('/opt/vaultwarden/compose.yaml')
candidate = pathlib.Path('/opt/vaultwarden/compose.pending.yaml')
candidate.write_bytes(base64.b64decode(settings['compose']))
candidate.chmod(0o644)
subprocess.run(['docker', 'compose', '-f', str(candidate), 'config', '--quiet'], check=True)
candidate.replace(compose_path)
subprocess.run(['docker', 'compose', '-f', str(compose_path), 'up', '-d', '--remove-orphans'], check=True)
'''


def main():
    settings = {
        "compose": os.environ["VAULTWARDEN_COMPOSE_BASE64"],
        "sso_enabled": os.environ["VAULTWARDEN_SSO_ENABLED"] == "true",
    }
    client_id = os.environ.get("VAULTWARDEN_GOOGLE_OAUTH2_CLIENT_ID")
    client_secret = os.environ.get("VAULTWARDEN_GOOGLE_OAUTH2_CLIENT_SECRET")
    if bool(client_id) != bool(client_secret):
        raise SystemExit("Provide both VAULTWARDEN_GOOGLE_OAUTH2_CLIENT_ID and VAULTWARDEN_GOOGLE_OAUTH2_CLIENT_SECRET")
    if client_id:
        settings["credentials"] = {"SSO_CLIENT_ID": client_id, "SSO_CLIENT_SECRET": client_secret}
    if os.environ.get("VAULTWARDEN_ADMIN_TOKEN"):
        settings["admin_token"] = os.environ["VAULTWARDEN_ADMIN_TOKEN"]
    script = base64.b64encode(REMOTE_UPDATE.encode()).decode()
    remote_command = f"sudo python3 -c \"import base64; exec(base64.b64decode('{script}'))\""
    with credentials() as (environment, options, _):
        result = subprocess.run(
            ["ssh", *options, f"ubuntu@{os.environ['VAULTWARDEN_HOST']}", remote_command],
            input=json.dumps(settings).encode(), env=environment,
        )
        if result.returncode:
            raise SystemExit("Vaultwarden configuration deployment failed")


if __name__ == "__main__":
    main()
