locals {
  voting_frontend_domain_name = "vedtatt.online.ntnu.no"
}

module "voting_frontend_bucket" {
  source = "../../modules/aws-s3-public-bucket"

  domain_name     = local.voting_frontend_domain_name
  certificate_arn = module.voting_frontend_bucket_certificate.certificate_arn
  zone_id         = data.aws_route53_zone.online_ntnu_no.zone_id
}
