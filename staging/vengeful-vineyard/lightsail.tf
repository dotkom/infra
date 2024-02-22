module "vengeful_vineyard_server_certificate" {
  source = "../../modules/aws-lightsail-certificate"

  certificate_name   = "vengeful-vineyard-server-staging"
  public_domain_name = local.vengeful_server_domain_name
}

module "vengeful_vineyard_server" {
  source = "../../modules/aws-lightsail-container-service"

  dns_zone_id           = data.aws_route53_zone.vinstraff_no.zone_id
  public_domain_name    = local.vengeful_server_domain_name
  service_name          = "vengeful-server-staging"
  environment_variables = data.doppler_secrets.vengeful.map
  image_tag             = "0.2.2"

  certificate_domain_validation_options = module.vengeful_vineyard_server_certificate.certificate_domain_validation_options
  certificate_name                      = module.vengeful_vineyard_server_certificate.certificate_name

  healthcheck_timeout = 10

  container_port = 8000
}
