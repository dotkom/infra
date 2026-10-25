"""One-time transfer to terraform/prod; never prints credential values."""
import base64
import json
from pathlib import Path
import subprocess
import sys

from runtime import credentials, temporary_key


def doppler_set(name, value):
    result = subprocess.run(
        ["doppler", "secrets", "set", name, "--project", "terraform", "--config", "prod", "--silent"],
        input=value.encode(), stdout=subprocess.PIPE, stderr=subprocess.PIPE,
    )
    if result.returncode:
        raise SystemExit(f"Could not store {name} in Doppler; no values printed")
    print(f"Stored {name}")


def main():
    if len(sys.argv) != 2:
        raise SystemExit('Usage: migrate-secrets.py <clouds.yaml path>')
    cloud = Path(sys.argv[1]).resolve()
    module = Path(__file__).resolve().parent.parent
    # Validate connectivity before exporting anything.
    with credentials() as (environment, ssh_options, paths):
        host = "129.241.100.5"
        ssh = ["ssh", *ssh_options, f"ubuntu@{host}"]
        subprocess.run([*ssh, "true"], check=True, env=environment)
        existing = subprocess.run(
            ["doppler", "secrets", "get", "VAULTWARDEN_SSH_PRIVATE_KEY", "--plain",
             "--project", "terraform", "--config", "prod"],
            stdout=subprocess.PIPE, stderr=subprocess.PIPE,
        )
        with temporary_key(existing.stdout if existing.returncode == 0 and existing.stdout.strip() else None) as (key_path, private_key):
            public = subprocess.check_output(["ssh-keygen", "-y", "-f", str(key_path)], text=True).strip()
            doppler_set("VAULTWARDEN_SSH_PRIVATE_KEY", private_key)
            remote = '''
import json, pathlib, sys
public = sys.stdin.read().strip() + ' vaultwarden-doppler'
path = pathlib.Path('/home/ubuntu/.ssh/authorized_keys')
lines = path.read_text().splitlines()
if not any(public.split()[1] in line for line in lines):
    with path.open('a') as stream:
        stream.write('\\nno-agent-forwarding,no-X11-forwarding ' + public + '\\n')
host_key = pathlib.Path('/etc/ssh/ssh_host_ed25519_key.pub').read_text().strip().split()
token = pathlib.Path('/srv/vaultwarden/secrets/initial-admin-token').read_text().strip()
print(json.dumps({'known_hosts': '129.241.100.5 ' + ' '.join(host_key[:2]), 'admin_token': token}))
'''
            encoded = base64.b64encode(remote.encode()).decode()
            command = f"sudo python3 -c \"import base64; exec(base64.b64decode('{encoded}'))\""
            result = subprocess.run([*ssh, command], input=public.encode(), stdout=subprocess.PIPE,
                                    stderr=subprocess.PIPE, env=environment)
            if result.returncode:
                raise SystemExit('VM credential transfer failed; no values printed')
            values = json.loads(result.stdout)
            doppler_set("VAULTWARDEN_SSH_KNOWN_HOSTS", values['known_hosts'])
            doppler_set("VAULTWARDEN_ADMIN_TOKEN", values['admin_token'])
        doppler_set("VAULTWARDEN_OPENSTACK_CLOUDS_YAML", cloud.read_text(encoding="utf-8-sig"))
        settings = (module / 'terraform.tfvars').read_text()
        settings = '\n'.join(line for line in settings.splitlines() if not line.startswith('deployment_ssh_public_key'))
        doppler_set("VAULTWARDEN_TERRAFORM_TFVARS", settings + '\ndeployment_ssh_public_key = ' + json.dumps(public) + '\n')
    print('Migration complete. AWS continues to use individual SSO logins.')


if __name__ == '__main__':
    main()
