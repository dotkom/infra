resource "vault_mount" "ssh_client_signer" {
  path = "ssh-client-signer"
  type = "ssh"
}

resource "vault_ssh_secret_backend_role" "ssh_client_signer_default" {
  name                    = "default"
  backend                 = vault_mount.ssh_client_signer.path
  key_type                = "ca"
  allow_user_certificates = true
  allowed_extensions      = "permit-pty,permit-port-forwarding"
  default_extensions = {
    "permit-pty"             = ""
    "permit-port-forwarding" = ""
  }
  allowed_users    = "*"
  default_user     = "dotkom"
  ttl              = 2764800
  max_ttl          = 2764800
  algorithm_signer = "rsa-sha2-512"
}

resource "vault_ssh_secret_backend_ca" "ssh_client_signer" {
  backend              = vault_mount.ssh_client_signer.path
  generate_signing_key = true
}
