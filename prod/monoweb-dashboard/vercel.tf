locals {
  dashboard_domain_name = "dashboard.online.ntnu.no"
}

module "vercel_project" {
  source = "../../modules/vercel-application"

  project_name   = "dashboard"
  domain_name    = local.dashboard_domain_name
  zone_id        = data.aws_route53_zone.online_ntnu_no.zone_id
  build_command  = "cd ../.. && pnpm build:dashboard"
  root_directory = "apps/dashboard"
}
