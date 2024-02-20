resource "vault_mount" "ssh_host_signer" {
  path = "ssh-host-signer"
  type = "ssh"
}

resource "vault_ssh_secret_backend_role" "default_ssh_host_signer" {
  name     = "default"
  backend  = vault_mount.ssh_host_signer.path
  key_type = "ca"

  allow_host_certificates = true
  allow_bare_domains      = true
  allow_subdomains        = true
  allowed_domains         = "online.ntnu.no"
  ttl                     = 276480000
  max_ttl                 = 276480000
  algorithm_signer        = "rsa-sha2-512"
}

resource "vault_ssh_secret_backend_ca" "ssh_host_signer" {
  backend              = vault_mount.ssh_host_signer.path
  generate_signing_key = true
}