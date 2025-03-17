locals {
  web_domain_name = "web-edge.online.ntnu.no"
}

module "vercel_project" {
  source = "../../modules/vercel-application"

  project_name   = "web"
  domain_name    = local.web_domain_name
  zone_id        = data.aws_route53_zone.online_ntnu_no.zone_id
  build_command  = "cd ../.. && pnpm build:web"
  root_directory = "apps/web"
}
