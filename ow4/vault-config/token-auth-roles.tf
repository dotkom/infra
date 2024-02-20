resource "vault_token_auth_backend_role" "nomad_cluster" {
  role_name              = "nomad-cluster"
  disallowed_policies    = ["nomad-server"]
  orphan                 = true
  token_period           = 86400
  renewable              = true
  token_explicit_max_ttl = "0"
}