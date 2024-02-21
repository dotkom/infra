data "doppler_secrets" "monoweb" {
  config  = "dev"
  project = "monoweb"
}

locals {
  forbidden_aws_lambda_keys = [
    "AWS_REGION",
    "AWS_DEFAULT_REGION",
    "AWS_ACCESS_KEY",
    "AWS_ACCESS_KEY_ID",
    "AWS_SECRET_ACCESS_KEY",
    "AWS_SESSION_TOKEN"
  ]

  monoweb_aws_safe_doppler_secrets = {
    for key, value in data.doppler_secrets.monoweb.map : key => value if !contains(local.forbidden_aws_lambda_keys, key)
  }
}
