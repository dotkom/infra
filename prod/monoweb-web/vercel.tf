locals {
  # TODO: Replace with online.ntnu.no once monoweb is shipped
  web_domain_name         = "web.online.ntnu.no"
  web_staging_domain_name = "web.staging.online.ntnu.no"
}

module "vercel_project" {
  source = "../../modules/vercel-application"

  project_name                  = "web"
  domain_name                   = local.web_domain_name
  staging_domain_name           = local.web_staging_domain_name
  staging_environment_variables = data.doppler_secrets.web_staging.map
  zone_id                       = data.aws_route53_zone.online_ntnu_no.zone_id
  build_command                 = "cd ../.. && pnpm build:web"
  root_directory                = "apps/web"
}
