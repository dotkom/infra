module "vengeful_vineyard_bucket_certificate" {
  source = "../../modules/aws-acm-certificate"

  domain  = local.vengeful_domain_name
  zone_id = local.zone_id

  providers = {
    aws.regional = aws.us-east-1
  }
}
