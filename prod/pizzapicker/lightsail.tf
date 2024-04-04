locals {
  pizzapicker_domain_name = "pizzapicker.online.ntnu.no"
}

module "pizzapicker_certificate" {
  source = "../../modules/aws-lightsail-certificate"

  certificate_name   = "pizzapicker-certificate-prod"
  public_domain_name = local.pizzapicker_domain_name
}

module "pizzapicker_server" {
  source = "../../modules/aws-lightsail-container-service"

  dns_zone_id           = data.aws_route53_zone.online_ntnu_no.zone_id
  public_domain_name    = local.pizzapicker_domain_name
  service_name          = "pizzapicker-prod"
  environment_variables = data.doppler_secrets.pizzapicker.map
  image_tag             = "latest"

  certificate_domain_validation_options = module.pizzapicker_certificate.certificate_domain_validation_options
  certificate_name                      = module.pizzapicker_certificate.certificate_name

  healthcheck_timeout = 10
  container_port = 3000
}
