module "backend_domain_certificate" {
  source = "../../modules/aws-acm-certificate"

  domain  = local.backend_domain_name
  zone_id = data.aws_route53_zone.grades_no.zone_id

  providers = {
    aws.regional = aws
  }
}
