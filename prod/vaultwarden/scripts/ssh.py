"""Use the shared Doppler key for SSH commands or the private admin tunnel."""
import os
import subprocess
import sys

from runtime import credentials


if __name__ == "__main__":
    with credentials() as (environment, options, _):
        host = os.environ.get("VAULTWARDEN_HOST", "129.241.100.5")
        arguments = sys.argv[1:]
        if arguments == ["--admin-tunnel"]:
            arguments = ["-N", "-L", "8080:127.0.0.1:8080"]
        remote = []
        if "--" in arguments:
            split = arguments.index("--")
            arguments, remote = arguments[:split], arguments[split + 1:]
        raise SystemExit(subprocess.call(["ssh", *options, *arguments, f"ubuntu@{host}", *remote], env=environment))
