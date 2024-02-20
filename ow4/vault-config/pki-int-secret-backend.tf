
resource "vault_mount" "pki_intermediate" {
  path                      = "pki_int"
  type                      = "pki"
  description               = "Intermediate CA"
  default_lease_ttl_seconds = 157680001
  max_lease_ttl_seconds     = 157680001
}

resource "vault_pki_secret_backend_intermediate_set_signed" "intermediate" {
  depends_on = [vault_pki_secret_backend_root_sign_intermediate.intermediate]
  backend    = vault_mount.pki_intermediate.path

  certificate = vault_pki_secret_backend_root_sign_intermediate.intermediate.certificate
}

resource "vault_pki_secret_backend_intermediate_cert_request" "intermediate" {
  depends_on = [vault_mount.pki_root]

  backend = vault_mount.pki_intermediate.path

  type        = "internal"
  common_name = "online.ntnu.no"
}

resource "vault_pki_secret_backend_root_sign_intermediate" "intermediate" {
  depends_on = [vault_pki_secret_backend_intermediate_cert_request.intermediate]

  backend = vault_mount.pki_root.path

  format               = "pem_bundle"
  csr                  = vault_pki_secret_backend_intermediate_cert_request.intermediate.csr
  common_name          = "online.ntnu.no"
  exclude_cn_from_sans = true
  ou                   = "dotkom"
  organization         = "Linjeforeningen Online"
}

resource "vault_pki_secret_backend_config_urls" "intermediate" {
  backend              = vault_mount.pki_intermediate.path
  issuing_certificates = ["https://vault.online.ntnu.no:8200/v1/pki_int/ca"]
}
