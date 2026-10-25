"""Materialize Doppler credentials for a command, then remove temporary files."""
from contextlib import contextmanager
import os
from pathlib import Path
import subprocess
import tempfile


def protect_file(path):
    path.chmod(0o600)
    if os.name == "nt":
        sid = subprocess.check_output(
            ["powershell", "-NoProfile", "-Command",
             "[System.Security.Principal.WindowsIdentity]::GetCurrent().User.Value"], text=True,
        ).strip()
        subprocess.run(["icacls", str(path), "/inheritance:r", "/remove:g", "*S-1-3-4",
                        "/grant:r", f"*{sid}:F", "*S-1-5-18:F"],
                       check=True, stdout=subprocess.DEVNULL)


@contextmanager
def private_directory():
    with tempfile.TemporaryDirectory(prefix="vaultwarden-") as directory:
        root = Path(directory)
        if os.name == "nt":
            sid = subprocess.check_output(
                ["powershell", "-NoProfile", "-Command",
                 "[System.Security.Principal.WindowsIdentity]::GetCurrent().User.Value"],
                text=True,
            ).strip()
            subprocess.run(
                ["icacls", str(root), "/inheritance:r", "/grant:r",
                 f"*{sid}:(OI)(CI)F", "*S-1-5-18:(OI)(CI)F"],
                check=True, stdout=subprocess.DEVNULL,
            )
        else:
            root.chmod(0o700)
        yield root


@contextmanager
def temporary_key(existing=None):
    with private_directory() as root:
        path = root / "id_ed25519"
        if existing:
            path.write_bytes(existing.rstrip() + b"\n")
        else:
            subprocess.run(["ssh-keygen", "-q", "-t", "ed25519", "-N", "", "-C",
                            "vaultwarden-doppler", "-f", str(path)], check=True)
        protect_file(path)
        yield path, path.read_text()


@contextmanager
def credentials():
    with private_directory() as root:
        environment = os.environ.copy()
        ssh_options = ["-o", "BatchMode=yes", "-o", "ConnectTimeout=10"]
        files = {
            "VAULTWARDEN_OPENSTACK_CLOUDS_YAML": "clouds.yaml",
            "VAULTWARDEN_SSH_PRIVATE_KEY": "id_ed25519",
            "VAULTWARDEN_SSH_KNOWN_HOSTS": "known_hosts",
            "VAULTWARDEN_TERRAFORM_TFVARS": "settings.tfvars",
        }
        paths = {}
        for variable, name in files.items():
            value = environment.get(variable)
            if value:
                path = root / name
                path.write_text(value.rstrip() + "\n", encoding="utf-8", newline="\n")
                protect_file(path)
                paths[variable] = path
        if "VAULTWARDEN_OPENSTACK_CLOUDS_YAML" in paths:
            environment["OS_CLIENT_CONFIG_FILE"] = str(paths["VAULTWARDEN_OPENSTACK_CLOUDS_YAML"])
        if "VAULTWARDEN_SSH_PRIVATE_KEY" in paths:
            if "VAULTWARDEN_SSH_KNOWN_HOSTS" not in paths:
                raise SystemExit("Shared SSH access requires VAULTWARDEN_SSH_KNOWN_HOSTS")
            ssh_options += ["-i", str(paths["VAULTWARDEN_SSH_PRIVATE_KEY"]),
                            "-o", "IdentitiesOnly=yes", "-o", "StrictHostKeyChecking=yes",
                            "-o", f"UserKnownHostsFile={paths['VAULTWARDEN_SSH_KNOWN_HOSTS']}"]
        else:
            ssh_options += ["-o", "StrictHostKeyChecking=yes"]
        yield environment, ssh_options, paths
