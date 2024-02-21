locals {
  web_project_name = "web-staging"
}

module "web_database" {
  source = "../modules/neon-project"

  project_name = local.web_project_name
  role_name    = "web"
}
