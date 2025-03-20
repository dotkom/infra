resource "grafana_service_account" "administrator" {
  name = "terraform-monorepo"
  role = "Admin"
}

resource "grafana_service_account_token" "terraform" {
  name               = "terraform-monorepo"
  service_account_id = grafana_service_account.administrator.id
}

resource "grafana_organization_preferences" "dotkom" {
  theme      = "system"
  timezone   = "browser"
  week_start = "monday"
}

output "service_token" {
  value     = grafana_service_account_token.terraform.key
  sensitive = true
}
