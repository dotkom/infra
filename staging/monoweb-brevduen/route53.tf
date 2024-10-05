locals {
  gateway_domain_name = "brevduen.staging.online.ntnu.no"
}

data "aws_route53_zone" "online_ntnu_no" {
  name = "online.ntnu.no"
}
