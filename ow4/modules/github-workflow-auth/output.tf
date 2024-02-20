output "token" {
  value     = vault_token.workflow.client_token
  sensitive = true
}
