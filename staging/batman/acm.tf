module "api_gateway_domain_certificate_http" {
  source = "../../modules/aws-acm-certificate"

  domain  = local.gateway_domain_name_http
  zone_id = data.aws_route53_zone.online_ntnu_no.zone_id

  providers = {
    aws.regional = aws
  }
}

module "api_gateway_domain_certificate_ws" {
  source = "../../modules/aws-acm-certificate"

  domain  = local.gateway_domain_name_ws
  zone_id = data.aws_route53_zone.online_ntnu_no.zone_id

  providers = {
    aws.regional = aws
  }
}