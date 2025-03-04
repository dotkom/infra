data "github_repository" "terraform_monorepo" {
  name = "terraform-monorepo"
}

resource "doppler_service_token" "prod" {
  name    = "terraform-github-actions-prod"
  project = "terraform"
  config  = "prod"
}

resource "doppler_service_token" "staging" {
  name    = "terraform-github-actions-staging"
  project = "terraform"
  config  = "staging"
}

resource "github_actions_secret" "prod_token" {
  secret_name     = "DOPPLER_PROD_SERVICE_TOKEN"
  repository      = data.github_repository.terraform_monorepo.name
  plaintext_value = doppler_service_token.prod.key
}

resource "github_actions_secret" "staging_token" {
  secret_name     = "DOPPLER_STAGING_SERVICE_TOKEN"
  repository      = data.github_repository.terraform_monorepo.name
  plaintext_value = doppler_service_token.staging.key
}
