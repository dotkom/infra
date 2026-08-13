module "frontend_domain_certificate" {
  source = "../../modules/aws-acm-certificate"

  domain  = local.frontend_domain_name
  zone_id = data.aws_route53_zone.grades_no.zone_id

  providers = {
    aws.regional = aws
  }
}

module "frontend_www_domain_certificate" {
  source = "../../modules/aws-acm-certificate"

  domain  = "www.${local.frontend_domain_name}"
  zone_id = data.aws_route53_zone.grades_no.zone_id

  providers = {
    aws.regional = aws
  }
}
