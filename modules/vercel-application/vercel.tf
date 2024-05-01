resource "vercel_project" "this" {
  name      = var.project_name
  framework = var.preset

  git_repository = {
    production_branch = "main"
    type              = "github"
    repo              = var.github_repository
  }

  build_command   = var.build_command
  install_command = var.install_command
  root_directory  = var.root_directory

  serverless_function_region = "arn1"

  ignore_command = "if [[ $VERCEL_GIT_COMMIT_REF =~ ^renovate ]]; then exit 0; else exit 1; fi"
}

resource "vercel_project_environment_variable" "environment_variables" {
  for_each = var.environment_variables

  project_id = vercel_project.this.id
  key        = each.key
  value      = sensitive(each.value)
  target     = ["preview", "development", "production"]
}

resource "vercel_project_domain" "domain" {
  domain     = aws_route53_record.domain.name
  project_id = vercel_project.this.id
}
