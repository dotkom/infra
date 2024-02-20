data "vault_generic_secret" "consul_master_token" {
  path = "secret/consul/acl/master"
}

resource "vault_consul_secret_backend" "consul" {
  path        = "consul"
  description = "Manages the Consul backend"

  address = "localhost:8500"
  token   = data.vault_generic_secret.consul_master_token.data.token
  scheme  = "http"
}

resource "vault_consul_secret_backend_role" "admin" {
  name     = "admin"
  backend  = vault_consul_secret_backend.consul.path
  max_ttl  = 2592000
  ttl      = 86400
  policies = ["admin"]
}

resource "vault_consul_secret_backend_role" "consul-server" {
  name     = "consul-server"
  backend  = vault_consul_secret_backend.consul.path
  max_ttl  = 86400
  ttl      = 86400
  policies = ["consul-server"]
}

resource "vault_consul_secret_backend_role" "vault-server" {
  name     = "vault-server"
  backend  = vault_consul_secret_backend.consul.path
  max_ttl  = 86400
  ttl      = 86400
  policies = ["vault-server"]
}

resource "vault_consul_secret_backend_role" "nomad-server" {
  name     = "nomad-server"
  backend  = vault_consul_secret_backend.consul.path
  max_ttl  = 86400
  ttl      = 86400
  policies = ["nomad-server"]
}

resource "vault_consul_secret_backend_role" "nomad-client" {
  name     = "nomad-client"
  backend  = vault_consul_secret_backend.consul.path
  max_ttl  = 86400
  ttl      = 86400
  policies = ["nomad-client"]
}
