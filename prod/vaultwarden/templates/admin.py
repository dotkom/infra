"""Generate instance admin credentials on the VM, outside Terraform state."""
import os
from pathlib import Path
import secrets

from argon2 import PasswordHasher

os.umask(0o077)
directory = Path("/srv/vaultwarden/secrets")
environment = directory / "vaultwarden.env"
if not environment.exists():
    token = secrets.token_urlsafe(48)
    hashed = PasswordHasher(time_cost=3, memory_cost=65536, parallelism=4).hash(token)
    # Single quotes prevent Compose from interpolating the hash's dollar signs.
    (directory / "initial-admin-token").write_text(token + "\n")
    environment.write_text(f"ADMIN_TOKEN='{hashed}'\n")
