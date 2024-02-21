locals {
  cdn_domain_name = "cdn.staging.online.ntnu.no"
}

module "static_bucket" {
  source          = "../modules/aws-s3-public-bucket"
  certificate_arn = module.cdn_domain_certificate.certificate_arn
  domain_name     = local.cdn_domain_name
  zone_id         = data.aws_route53_zone.online_ntnu_no.zone_id

  depends_on = [module.cdn_domain_certificate]
}
