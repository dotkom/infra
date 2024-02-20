resource "vault_mount" "pki_root" {
  path                      = "pki"
  type                      = "pki"
  description               = "Root CA"
  default_lease_ttl_seconds = 157680001
  max_lease_ttl_seconds     = 315360001
}

resource "vault_pki_secret_backend_config_urls" "root" {
  backend              = vault_mount.pki_root.path
  issuing_certificates = ["https://vault.online.ntnu.no:8200/v1/pki/ca"]
}

resource "vault_pki_secret_backend_root_cert" "root" {
  depends_on = [vault_mount.pki_root]

  backend = vault_mount.pki_root.path

  type                 = "internal"
  common_name          = "online.ntnu.no"
  ttl                  = 315360000
  format               = "pem"
  private_key_format   = "der"
  key_type             = "rsa"
  key_bits             = 4096
  exclude_cn_from_sans = true
  ou                   = "dotkom"
  organization         = "Linjeforeningen Online"
}
