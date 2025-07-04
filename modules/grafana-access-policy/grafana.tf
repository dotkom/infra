resource "grafana_cloud_access_policy" "grafana" {
  region       = var.grafana_region
  name         = var.policy_name
  display_name = "Grafana Cloud Access for ${var.policy_name}"

  scopes = [
    "metrics:write",
    "logs:write",
    "traces:write",
  ]

  realm {
    type       = "stack"
    identifier = var.grafana_stack
  }
}

resource "grafana_cloud_access_policy_token" "grafana" {
  region           = var.grafana_region
  access_policy_id = grafana_cloud_access_policy.grafana.policy_id
  name             = var.policy_name
  display_name     = "Grafana Cloud Access for ${var.policy_name}"
}
