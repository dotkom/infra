locals {
  cdn_domain_name = "cdn.dev.online.ntnu.no"
}

data "aws_route53_zone" "online_ntnu_no" {
  name = "online.ntnu.no"
}

module "cdn_domain_certificate" {
  source = "../../modules/aws-acm-certificate"

  domain  = local.cdn_domain_name
  zone_id = data.aws_route53_zone.online_ntnu_no.zone_id

  providers = {
    aws.regional = aws.us-east-1
  }
}

module "static_bucket" {
  source          = "../../modules/aws-s3-public-bucket"
  certificate_arn = module.cdn_domain_certificate.certificate_arn
  domain_name     = local.cdn_domain_name
  zone_id         = data.aws_route53_zone.online_ntnu_no.zone_id
  cors_allowed_origins = [
    "http://localhost:3000",
    "http://localhost:3002"
  ]

  depends_on = [module.cdn_domain_certificate]
}
