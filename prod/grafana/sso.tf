resource "grafana_team" "dotkom" {
  name    = "dotkom"
  members = []

  lifecycle {
    ignore_changes = [members]
  }
}

resource "grafana_sso_settings" "google_workspace" {
  provider_name = "google"
  oauth2_settings {
    name          = "Google"
    client_id     = data.doppler_secrets.terraform.map["GRAFANA_GOOGLE_CLIENT_ID"]
    client_secret = data.doppler_secrets.terraform.map["GRAFANA_GOOGLE_CLIENT_SECRET"]

    allow_sign_up         = true
    scopes                = "openid email profile"
    allowed_organizations = join(",", ["dotkom"])
    allowed_domains       = "online.ntnu.no"

    use_pkce = true
  }
}
