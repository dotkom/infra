output "token" {
  value = grafana_cloud_access_policy_token.grafana.token
}

output "policy_id" {
  value = grafana_cloud_access_policy.grafana.policy_id
}

output "grafana_stack" {
  value = var.grafana_stack
}
