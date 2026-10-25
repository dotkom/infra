"""Run from Doppler: python prod/vaultwarden/scripts/terraform.py plan ..."""
from pathlib import Path
import subprocess
import sys

from runtime import credentials


def main():
    if len(sys.argv) < 2:
        raise SystemExit("Usage: terraform.py <terraform command> [arguments]")
    module = Path(__file__).resolve().parent.parent
    arguments = sys.argv[1:]
    with credentials() as (environment, _, paths):
        settings = paths.get("VAULTWARDEN_TERRAFORM_TFVARS")
        if arguments[0] in ("plan", "apply", "import", "refresh", "console", "destroy"):
            saved_plan = arguments[0] == "apply" and any(arg.endswith(".tfplan") for arg in arguments[1:])
            if settings and not saved_plan:
                arguments.append(f"-var-file={settings}")
        raise SystemExit(subprocess.call(["terraform", f"-chdir={module}", *arguments], env=environment))


if __name__ == "__main__":
    main()
