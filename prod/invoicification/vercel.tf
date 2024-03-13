locals {
  invoicification_domain_name = "faktura.online.ntnu.no"
}

module "vercel_project" {
  source = "../../modules/vercel-application"

  project_name   = "invoicification"
  domain_name    = local.invoicification_domain_name
  zone_id        = data.aws_route53_zone.online_ntnu_no.zone_id
  build_command  = "cd ../.. && pnpm build:invoicification"
  root_directory = "apps/invoicification"
}
