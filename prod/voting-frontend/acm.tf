module "voting_frontend_bucket_certificate" {
  source = "../../modules/aws-acm-certificate"

  domain  = local.voting_frontend_domain_name
  zone_id = data.aws_route53_zone.online_ntnu_no.zone_id

  providers = {
    aws.regional = aws.us-east-1
  }
}
