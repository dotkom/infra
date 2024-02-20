resource "vault_pki_secret_backend_role" "operator" {
  backend    = vault_mount.pki_intermediate.path
  name       = "operator"
  ttl        = 2592000
  max_ttl    = 2592000
  require_cn = false
  key_usage  = ["DigitalSignature", "KeyAgreement", "KeyEncipherment"]
}

resource "vault_pki_secret_backend_role" "consul_client" {
  backend            = vault_mount.pki_intermediate.path
  name               = "consul-client"
  ttl                = 86400
  max_ttl            = 2592000
  allow_localhost    = true
  allowed_domains    = ["client.consul"]
  allow_bare_domains = true
  generate_lease     = true
  key_usage          = ["DigitalSignature", "KeyAgreement", "KeyEncipherment"]
}

resource "vault_pki_secret_backend_role" "consul_server" {
  backend            = vault_mount.pki_intermediate.path
  name               = "consul-server"
  ttl                = 86400
  max_ttl            = 86400
  allow_localhost    = true
  allowed_domains    = ["consul", "online.ntnu.no"]
  allow_bare_domains = true
  allow_subdomains   = true
  generate_lease     = true
  key_usage          = ["DigitalSignature", "KeyAgreement", "KeyEncipherment"]
}


resource "vault_pki_secret_backend_role" "nomad_client" {
  backend            = vault_mount.pki_intermediate.path
  name               = "nomad-client"
  ttl                = 86400
  max_ttl            = 2592000
  allow_localhost    = true
  allowed_domains    = ["client.global.nomad"]
  allow_bare_domains = true
  generate_lease     = true
  key_usage          = ["DigitalSignature", "KeyAgreement", "KeyEncipherment"]
}

resource "vault_pki_secret_backend_role" "nomad_server" {
  backend            = vault_mount.pki_intermediate.path
  name               = "nomad-server"
  ttl                = 86400
  max_ttl            = 86400
  allow_localhost    = true
  allowed_domains    = ["nomad", "online.ntnu.no"]
  allow_bare_domains = true
  allow_subdomains   = true
  generate_lease     = true
  key_usage          = ["DigitalSignature", "KeyAgreement", "KeyEncipherment"]
}