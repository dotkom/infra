# Vaultwarden on NTNU OpenStack

A dedicated Ubuntu 24.04 VM in the existing `stack.it.ntnu.no` project serves
`https://vault.online.ntnu.no`. Terraform creates the VM, persistent Cinder data
volume, network port, security group, floating IP and Route 53 A record. It uses
the existing project network and router; it does not create a new OpenStack project.

## Current deployment

Deployed in `STUDORG_online`, TRD1. The public IPv4 address is `129.241.100.5`
and the VM UUID is `9306a3fd-dac4-4d49-b47d-b3f3f1937451`. State is stored at
the repository's existing S3 backend under `vaultwarden.tfstate`.

Verified after deployment: the web vault and `/alive` return HTTP 200, HTTP
redirects to HTTPS, the certificate is valid for `vault.online.ntnu.no`, the
public `/admin` route returns 404, and Terraform reports no changes. OpenStack
console output confirms cloud-init completed and the daily backup timer started.

SSH works through the administrator's VPN after allowing its source address
`10.52.251.110/32`. Direct Google SSO is enabled using the internal app in Google
Cloud project `online-vaultwarden`. Brage confirmed successful SSO login and
initial master-password setup. The Online organization and its Online and Dotkom
collections still need creation. SMTP and encrypted off-site backups also need
configuration.

## Access model

Use **one Online organization**, one collection per committee, and an **Online**
collection shared with members. Initially create Online and Dotkom collections
with `brage.andreas.hoven@online.ntnu.no`. Assign each member their committee
collection and Online explicitly. Group support is not enabled in this deployment.
Use ordinary User roles
with access only to assigned collections, never access to all collections.

Online organization Owners and Admins can access all committee collections.
This model provides privacy between ordinary committee members, not from Online's
organization administrators. Keep those roles limited to trusted custodians.
Individual users also retain their personal vaults. Folder names and nested
collection names do not establish access permissions: assign each collection's
permissions explicitly. Verify access with accounts from two different committees.

Organizations, collections, groups, accounts and encrypted organization keys are
created in Vaultwarden after deployment, not by Terraform. Terraform provisions
the server; it does not manage users' master passwords or encryption keys.

## Team deployment through Doppler

The shared `terraform/prod` configuration now contains:

- `VAULTWARDEN_OPENSTACK_CLOUDS_YAML`: the existing project application credential
  and connection settings. It is used without a local `clouds.yaml`.
- `VAULTWARDEN_SSH_PRIVATE_KEY`: a dedicated shared Ed25519 deployment key for
  this VM. Brage's personal private key was not copied.
- `VAULTWARDEN_SSH_KNOWN_HOSTS`: the VM's verified SSH host key, obtained through
  the existing trusted SSH connection. Unknown or changed host keys are rejected.
- `VAULTWARDEN_ADMIN_TOKEN`: the existing server-admin credential. This controls
  the server admin panel; it does not unlock any user's vault.
- `VAULTWARDEN_TERRAFORM_TFVARS`: shared deployment settings, including allowed
  SSH CIDRs, Google SSO enablement and the shared public key for new VMs.
- `VAULTWARDEN_GOOGLE_OAUTH2_CLIENT_ID` and
  `VAULTWARDEN_GOOGLE_OAUTH2_CLIENT_SECRET`: Google's login client credentials.

Access to these Doppler secrets gives server administration access. Restrict
`terraform/prod` to trusted infrastructure administrators. Organization ownership
and committee permissions are managed separately in Vaultwarden.

Install Terraform, Python 3, OpenSSH, Doppler CLI and AWS CLI. Log into Doppler
with your own account and AWS with your own authorized SSO profile. From the
repository root, use:

```powershell
aws sso login --profile YOUR_AWS_PROFILE
$env:AWS_PROFILE = "YOUR_AWS_PROFILE"
doppler run --project terraform --config prod -- python prod/vaultwarden/scripts/terraform.py init
doppler run --project terraform --config prod -- python prod/vaultwarden/scripts/terraform.py plan -out=team.tfplan
doppler run --project terraform --config prod -- python prod/vaultwarden/scripts/terraform.py apply team.tfplan
```

Saved plan paths are relative to `prod/vaultwarden`. The wrapper supplies the
shared variable file explicitly, so it takes precedence over a local
`terraform.tfvars`. No local secrets file or personal SSH key is needed. Temporary
credential files have private permissions and are deleted when the command ends.
On Windows, explicit ACLs restrict them to the current user and SYSTEM.

Your network source must also be in `ssh_allowed_cidrs`. Add an administrator's
specific VPN/public CIDR to the shared settings and apply the security-group
change; do not expose SSH to the whole internet. AWS still requires permissions
to the S3 state backend and Route 53; Google client management requires Google
Cloud IAM access to `online-vaultwarden`. Doppler does not grant those permissions.

To access the private server admin panel:

```sh
doppler run --project terraform --config prod -- python prod/vaultwarden/scripts/ssh.py --admin-tunnel
```

Keep that command running, open `http://localhost:8080/admin`, and use
`VAULTWARDEN_ADMIN_TOKEN` from Doppler. For a remote command:

```sh
doppler run --project terraform --config prod -- python prod/vaultwarden/scripts/ssh.py -- sudo systemctl is-active vaultwarden
```

Changing only a runtime secret in Doppler does not change a Terraform resource.
To deploy a rotated Google secret or server admin token, run the plan command with
`-replace=terraform_data.configuration`, review it, then apply its saved plan.
The admin token is hashed with Argon2 on the VM. Credential values do not become
Terraform variable values or state entries. Runtime copies on the VM remain
necessary for the service to run without a Doppler connection.

The one-time `scripts/migrate-secrets.py` copied the existing credentials and
installed the dedicated key. Original ignored local OpenStack files remain as
fallback copies; normal team commands do not use them. AWS SSO sessions, personal
SSH keys, users' master passwords and vault encryption keys are not exported to
Doppler. Backup and SMTP credentials can be added when those services are selected;
neither is configured yet.

## Initial deployment with local OpenStack credentials

1. Place the downloaded `clouds.yaml` in the repository root. It is ignored by
   Git. The default named cloud is `openstack`; override `openstack_cloud` if
   needed. The Horizon download may omit the password: provide it locally or
   use a scoped application credential before deployment. Keep credentials out
   of tracked files and Terraform variables. Use the actual Keystone endpoint
   from the configuration, not `https://stack.it.ntnu.no`.

   For NTNU SSO accounts, sign into Horizon, select the correct project and TRD1
   region, then open **Identity → Application Credentials**. Create a credential
   for this Terraform deployment and download its `clouds.yaml` to replace the
   root file. The generic clouds.yaml download identifies your account but does
   not contain the browser's SSO session. See
   [NTNU's Terraform guide](https://www.ntnu.no/wiki/spaces/skyhigh/pages/477955333/Terraform).
2. Authenticate AWS for the existing S3 Terraform backend and Route 53 zone.
   This deployment uses AWS SSO. Refresh the session with:

   ```sh
   aws sso login --profile AdministratorAccess-891459268445
   ```

   This repository uses Doppler's `terraform/prod` configuration for Terraform
   secrets. Run Terraform through `doppler run --project terraform --config prod --`
   when those secrets are needed. Doppler supplies Terraform variables; the AWS
   provider and S3 backend authenticate through the SSO profile separately.
3. Copy `terraform.tfvars.example` to `terraform.tfvars` and replace every
   placeholder. Select a public floating-IP pool, an existing network with
   outbound internet access, an Ubuntu 24.04 cloud image, and a flavor with
   at least 2 GiB RAM and a 20 GiB local root disk. Use your administrator/VPN
   IPv4 CIDRs for SSH and the initial Online owner email for organization creation.
4. From this directory:

   Set `OS_CLIENT_CONFIG_FILE` to the absolute path of the root configuration,
   because Terraform runs in `prod/vaultwarden`, not the repository root. In
   PowerShell:

   ```powershell
   $env:OS_CLIENT_CONFIG_FILE = (Resolve-Path ../../clouds.yaml).Path
   $env:AWS_PROFILE = "AdministratorAccess-891459268445"
   ```

   If the credential download is named `clouds (1).yaml`, use
   `(Resolve-Path '../../clouds (1).yaml').Path` instead. Both filenames are ignored
   by Git. Use the AWS profile that actually grants access if `dotkom` is absent.

   Or in Bash:

   ```sh
   export OS_CLIENT_CONFIG_FILE="$(cd ../.. && pwd)/clouds.yaml"
   export AWS_PROFILE=AdministratorAccess-891459268445
   ```

   ```sh
   terraform init
   terraform plan -out=vaultwarden.tfplan
   terraform apply vaultwarden.tfplan
   ```

5. SSH as `ubuntu` to the `floating_ip` output. Run `sudo cloud-init status --wait`,
   then `sudo systemctl status vaultwarden` and
   `sudo docker compose -f /opt/vaultwarden/compose.yaml ps`.
   Check `/var/log/cloud-init-output.log` if initialization fails.
6. Wait for DNS propagation and Caddy to obtain a trusted HTTPS certificate.
   The public floating IP must accept TCP 80 and 443 from the internet. NTNU's
   external network/firewall policy must also permit this; a security group alone
   cannot override an upstream firewall.

A successful Terraform apply does not prove that cloud-init or certificate
issuance succeeded; verify the running service using the checks above.

### STUDORG_online resource selections

The local `terraform.tfvars` selects the existing `minecraft-server-net`, the
public IPv4 floating-IP subnet in `ntnu-exposed`, the active Ubuntu Server 24.04
LTS image and `gx3.1c2r` (1 vCPU, 2 GiB RAM, 40 GiB root disk). It also selects
the existing `brage-it2901-pem` SSH key pair; the administrator must have its
private key. No existing VM or router is modified. Organization creation is
restricted to `leder@online.ntnu.no` and `brage.andreas.hoven@online.ntnu.no`.
SSH allows `129.241.236.110/32` and the VPN source `10.52.251.110/32`.

Check that project quotas have at least 1 vCPU and 2 GiB RAM available before
applying. If capacity is exhausted, request more quota or separately approve an
existing VM resize after assessing that service's needs. Do not apply just to
discover a quota error: Terraform could leave partially created network/storage/DNS
resources. AWS authentication is also required for the state backend and Route 53
record. If a spare floating IP has been released rather than left allocated and
unassociated, Terraform allocates a new one from the selected public subnet.

## Google SSO

The integration uses Google directly, without Auth0. It is enabled in the current
deployment. To register a replacement integration:

1. Sign into [Google Cloud Console](https://console.cloud.google.com/) with your
   Online Google account. Select or create a project under Online's organization.
   If project creation is denied, an Online Google administrator must grant access
   or create the project.
2. Open **Google Auth Platform**, choose **Get started**, name the application
   **Online Vaultwarden**, and use your Online address as the contact. Choose
   **Internal** audience. If Internal is unavailable, check that the project belongs
   to Online's Google Workspace organization before continuing.
3. In **Clients**, create a **Web application** client named **Online Vaultwarden**.
   Set the authorized JavaScript origin to `https://vault.online.ntnu.no` and the
   redirect URI to `https://vault.online.ntnu.no/identity/connect/oidc-signin`.
   Login requests only OpenID identity, email and profile scopes.
4. Store the client ID and client secret in Doppler `terraform/prod` as
   `VAULTWARDEN_GOOGLE_OAUTH2_CLIENT_ID` and `VAULTWARDEN_GOOGLE_OAUTH2_CLIENT_SECRET`.
   Never put the secret in Terraform variables or chat.
5. Set `google_sso_enabled = true` in local `terraform.tfvars`. Run plan and apply
   through Doppler. The deployment script sends the credentials over SSH stdin
   into the root-only server environment file; they are not Terraform state values.
6. Verify that an Online account can register via SSO and another domain cannot.
   Configure any required Google Workspace app approval with an administrator.

The server requires SSO when enabled, restricts registration to `online.ntnu.no`,
and requires Google to report verified email addresses. The Google `hd` parameter
is an account-selection hint; it is not the access restriction. Internal audience
and server registration restrictions provide the access controls.

Google authentication still requires a Vaultwarden master password to encrypt
and unlock the vault. Each user chooses that password themselves on first login.
Authentication does not assign collections: a separate membership service will
manage organization membership and collection permissions.

See [Vaultwarden's Google SSO instructions](https://github.com/dani-garcia/vaultwarden/wiki/Enabling-SSO-support-using-OpenId-Connect)
and [Google's client creation guide](https://developers.google.com/workspace/guides/create-credentials).

## Initial accounts and committees

Public registration is disabled. The admin panel is blocked at the public HTTPS
proxy and is available only through SSH:

```sh
ssh -L 8080:127.0.0.1:8080 ubuntu@PUBLIC_IP
```

Open `http://localhost:8080/admin`. Use `VAULTWARDEN_ADMIN_TOKEN` from Doppler.
The initial bootstrap copy on the VM is available with
`sudo cat /srv/vaultwarden/secrets/initial-admin-token`; after a token rotation,
that initial copy may be stale.
It is generated on the VM, with an Argon2 hash in the server environment file;
neither credential is put in Terraform state or cloud-init metadata.

1. Configure your authorized SMTP relay in the admin panel and send a test email.
   Set the SMTP host, TLS mode, port, sender and credentials for your relay.
   Keep public registration disabled and organization invitations enabled.
2. Invite the initial owner email using the server admin panel. Follow the email
   invitation to register at the public HTTPS URL and enable two-factor authentication.
3. That account creates the Online organization and its Online and Dotkom collections.
4. Invite committee members from the organization admin console. Complete the
   invitation acceptance and owner confirmation steps. Assign ordinary User roles,
   explicit collection permissions. Grant Online access to
   every intended member; give edit permission only to those who need it.
5. Add a second trusted Online owner for recovery, and verify that a member of
   committee A cannot view committee B's items. Test Shared access separately.

Existing `config.json` settings saved through the admin panel override environment
settings. Review the admin panel when changing registration or other server settings.
Users point Bitwarden clients at `https://vault.online.ntnu.no` as their self-hosted
server before signing in.

## Storage, backups and upgrades

`/srv/vaultwarden` is a separate ext4 Cinder volume. The setup script resolves the
volume by its virtio serial and refuses to format a disk with existing signatures.
If your NTNU image exposes disks differently, initialization fails; inspect disk
IDs and adapt the script instead of guessing a device name.

The data volume and VM have `prevent_destroy` guards. Terraform ignores changes
to the VM's initial cloud-init data and deploys Compose updates over SSH using
`scripts/deploy.py`. Python and an SSH agent with the administrator key are needed
on the machine running Terraform. Existing admin-panel configuration overrides
cause the script to stop for review. Back up before changing pinned image versions,
then plan and apply. Other bootstrap files require a separate maintenance update.
Keep the data volume attached and mounted. A deliberate
VM replacement requires a maintenance procedure, retention of the volume and
removal of the VM guard; a new VM runs cloud-init against the retained volume.

The daily systemd timer backs up the database (including its matching WAL),
attachments, keys, settings and host secrets to root-only archives on the data
volume. Vaultwarden stops briefly to ensure consistency. About 14 days of archives
are retained. Check `systemctl list-timers` and
`journalctl -u vaultwarden-backup.service`; run `sudo vaultwarden-backup` to test.

**Local archives do not protect against loss of the volume or OpenStack project.**
Encrypted off-site backup support is included but needs a repository configured
before storing real passwords. As root, create mode-0600
`/srv/vaultwarden/secrets/restic.env` with `RESTIC_REPOSITORY`,
`RESTIC_PASSWORD_FILE` and any repository credentials. Keep the repository password
file on the VM and a recovery copy outside this server. Initialize the repository
with those variables exported and `restic init`, then run `vaultwarden-backup`
and check `restic snapshots`. The script copies each archive with encryption and
retains 14 daily, 8 weekly and 12 monthly snapshots. Archives include server
credentials, so encrypt them whenever they leave the VM.

Test a restore on an isolated VM: stop Vaultwarden, preserve the existing `data`
and `secrets` directories, extract a complete archive into an empty restore path,
and restore those two directories together under `/srv/vaultwarden`. Do not mix
database files with old WAL files. Restart and verify login, organization access
and attachments. Caddy certificates are regenerated if its data is lost.

## References

- [Vaultwarden](https://github.com/dani-garcia/vaultwarden)
- [Docker Compose deployment](https://github.com/dani-garcia/vaultwarden/wiki/Using-Docker-Compose)
- [Backup and restore](https://github.com/dani-garcia/vaultwarden/wiki/Backing-up-your-vault)
- [Server configuration](https://github.com/dani-garcia/vaultwarden/blob/main/.env.template)
- [NTNU OpenStack web interface](https://www.ntnu.no/wiki/spaces/skyhigh/pages/98079250/Using+the+webinterface)
