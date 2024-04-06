locals {
  app_public_domain_name = "grades.no"
  api_public_domain_name = "api.grades.no"
}

module "gradestats_server_certificate" {
  source = "../../modules/aws-lightsail-certificate"

  certificate_name   = "grades-server-prd"
  public_domain_name = local.api_public_domain_name
}

module "gradestats_server" {
  source = "../../modules/aws-lightsail-container-service"

  dns_zone_id           = data.aws_route53_zone.grades.zone_id
  public_domain_name    = local.api_public_domain_name
  service_name          = "gradestats-server-prd"
  environment_variables = data.doppler_secrets.grades.map
  image_tag             = "0.1.1"

  certificate_domain_validation_options = module.gradestats_server_certificate.certificate_domain_validation_options
  certificate_name                      = module.gradestats_server_certificate.certificate_name

  container_port = 8081
}

module "gradestats_web_certificate" {
  source = "../../modules/aws-lightsail-certificate"

  certificate_name   = "grades-web-prd"
  public_domain_name = local.app_public_domain_name
}

module "gradestats_web" {
  source = "../../modules/aws-lightsail-container-service"

  dns_zone_id           = data.aws_route53_zone.grades.zone_id
  public_domain_name    = local.app_public_domain_name
  service_name          = "gradestats-web-prd"
  environment_variables = data.doppler_secrets.grades.map
  image_tag             = "0.1.2"

  certificate_domain_validation_options = module.gradestats_web_certificate.certificate_domain_validation_options
  certificate_name                      = module.gradestats_web_certificate.certificate_name

  container_port = 3000
}
