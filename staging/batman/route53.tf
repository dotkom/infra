locals {
  gateway_domain_name_http = "batmanhttp.staging.online.ntnu.no"
  gateway_domain_name_ws = "batmanws.staging.online.ntnu.no"
}

data "aws_route53_zone" "online_ntnu_no" {
  name = "online.ntnu.no"
}
