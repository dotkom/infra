resource "github_actions_secret" "vault_token" {
  repository      = var.repo_name
  secret_name     = "VAULT_TOKEN"
  plaintext_value = vault_token.workflow.client_token
}

resource "vault_token" "workflow" {
  role_name = vault_token_auth_backend_role.workflow.role_name
  period    = var.token_period
  policies  = concat([vault_policy.workflow.name], var.additional_vault_policies)
}
resource "vault_policy" "workflow" {
  name = "gh-workflow/${var.role_name}"

  policy = <<EOT
    path "secret/data/gh-workflows/*" {
      capabilities = ["list", "read"]
    }

    path "aws/creds/gh-workflow-${var.role_name}" {
      capabilities = ["read"]
    }
EOT
}

resource "vault_token_auth_backend_role" "workflow" {
  role_name        = "gh-workflow-${var.role_name}"
  allowed_policies = concat([vault_policy.workflow.name], var.additional_vault_policies)
  orphan           = true
  renewable        = false
  token_period     = var.token_period
}

resource "vault_aws_secret_backend_role" "workflow" {
  count           = var.aws_policy_document != null ? 1 : 0
  backend         = "aws"
  name            = "gh-workflow-${var.role_name}"
  credential_type = "iam_user"
  policy_document = var.aws_policy_document
}
