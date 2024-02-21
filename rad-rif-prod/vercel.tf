locals {
  rad_rif_domain_name = "interesse.online.ntnu.no"
}

module "vercel_project" {
  source = "../modules/vercel-application"

  project_name   = "rif"
  domain_name    = local.rad_rif_domain_name
  zone_id        = data.aws_route53_zone.online_ntnu_no.zone_id
  build_command  = "cd ../.. && pnpm build:rif"
  root_directory = "apps/rif"
}
