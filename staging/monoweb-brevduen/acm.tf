module "brevduen_domain_certificate" {
  source = "../../modules/aws-acm-certificate"

  domain  = local.brevduen_domain_name
  zone_id = data.aws_route53_zone.online_ntnu_no.zone_id

  providers = {
    aws.regional = aws
  }
}
