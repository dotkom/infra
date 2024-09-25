moved {
  from = module.rif_certificate
  to   = module.invoicification_certificate
}

module "invoicification_certificate" {
  source = "../../modules/aws-acm-certificate"

  domain  = local.invoicification_domain_name
  zone_id = data.aws_route53_zone.online_ntnu_no.zone_id

  providers = {
    aws.regional = aws
  }
}
