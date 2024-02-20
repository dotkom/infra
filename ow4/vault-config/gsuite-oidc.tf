data "vault_generic_secret" "gsuite_oidc_credentials" {
  path = "secret/gcp-oidc-for-vault"
}

data "vault_generic_secret" "gsuite_service_account" {
  path = "secret/gcp-vault-service-account-key"
}

resource "vault_jwt_auth_backend" "gcp" {
  description        = "GCP(Gsuite) OIDC"
  path               = "oidc"
  type               = "oidc"
  oidc_discovery_url = "https://accounts.google.com"
  oidc_client_id     = data.vault_generic_secret.gsuite_oidc_credentials.data["client_id"]
  oidc_client_secret = data.vault_generic_secret.gsuite_oidc_credentials.data["client_secret"]

  tune {
    default_lease_ttl  = "768h"
    max_lease_ttl      = "768h"
    listing_visibility = "unauth"
    token_type         = "default-service"
  }

  default_role = "dotkom"
  provider_config = {
    "provider"                 = "gsuite"
    "gsuite_service_account"   = data.vault_generic_secret.gsuite_service_account.data_json
    "gsuite_admin_impersonate" = "tobias.slettemoen.kongsvik@online.ntnu.no" // Maybe create an admin account just for this
    "fetch_groups"             = "true"
    "fetch_user_info"          = "true"
    "groups_recurse_max_depth" = "5"
  }
}

resource "vault_jwt_auth_backend_role" "dotkom" {
  backend        = vault_jwt_auth_backend.gcp.path
  role_name      = "dotkom"
  token_policies = ["dotkom"]

  user_claim   = "sub"
  groups_claim = "groups"
  bound_claims = {
    "groups" = "dotkom@online.ntnu.no"
  }
  role_type             = "oidc"
  allowed_redirect_uris = ["https://vault.online.ntnu.no:8200/ui/vault/auth/oidc/oidc/callback", "http://localhost:8250/oidc/callback"]
}

resource "vault_jwt_auth_backend_role" "admin" {
  backend        = vault_jwt_auth_backend.gcp.path
  role_name      = "admin"
  token_policies = ["admin"]

  user_claim   = "sub"
  groups_claim = "groups"
  bound_claims = {
    "groups" = "dotkom@online.ntnu.no"
  }
  role_type             = "oidc"
  allowed_redirect_uris = ["https://vault.online.ntnu.no:8200/ui/vault/auth/oidc/oidc/callback", "http://localhost:8250/oidc/callback"]
}