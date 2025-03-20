locals {
  domain_name = "splash.online.ntnu.no"
}

data "aws_route53_zone" "zone" {
  name = "online.ntnu.no"
}

module "domain_certificate" {
  source = "../../modules/aws-acm-certificate"

  domain  = local.domain_name
  zone_id = data.aws_route53_zone.zone.id

  providers = {
    aws.regional = aws.us-east-1
  }
}


module "static_bucket" {
  source          = "../../modules/aws-s3-public-bucket"
  certificate_arn = module.domain_certificate.certificate_arn
  domain_name     = local.domain_name
  zone_id         = data.aws_route53_zone.zone.id
  depends_on      = [module.domain_certificate]
}
