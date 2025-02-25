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

  ignore_command = "if [[ $VERCEL_GIT_COMMIT_REF =~ ^renovate ]]; then exit 0; else npx turbo-ignore --fallback=HEAD^; fi"
}

resource "vercel_custom_environment" "staging" {
  count       = var.staging_domain_name != null ? 1 : 0
  project_id  = vercel_project.this.id
  name        = "staging"
  description = "Staging environment"
  branch_tracking = {
    pattern = "main"
    type = "equals"
  }
}

resource "vercel_project_environment_variable" "environment_variables" {
  for_each = var.environment_variables

  project_id = vercel_project.this.id
  key        = each.key
  value      = sensitive(each.value)
  target     = concat(
    ["preview", "development", "production"],
    var.staging_domain_name != null ? ["staging"] : [],
  )
}

resource "vercel_project_environment_variables" "staging_environment_variables" {
  count     = var.staging_domain_name != null ? 1 : 0
  project_id = vercel_project.this.id
  variables  = toset([
    for key, value in var.staging_environment_variables : {
      key = key
      value = sensitive(value)
      custom_environment_ids = [vercel_custom_environment.staging[0].id]
      sensitive = true
    }
  ])
  // custom_environment_ids = [vercel_custom_environment.staging[0].id]
}

resource "vercel_project_domain" "domain" {
  domain     = aws_route53_record.domain.name
  project_id = vercel_project.this.id
}

resource "vercel_project_domain" "staging_domain" {
  count     = var.staging_domain_name != null ? 1 : 0
  domain     = aws_route53_record.staging_domain[0].name
  project_id = vercel_project.this.id
  custom_environment_id = vercel_custom_environment.staging[0].id
}
