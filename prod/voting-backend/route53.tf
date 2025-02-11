locals {
  voting_domain_name = "api.vedtatt.online.ntnu.no"
}

data "aws_route53_zone" "online_ntnu_no" {
  name = "online.ntnu.no"
}

data "aws_lb" "evergreen_gateway" {
  name = "evergreen-prod-gateway"
}

resource "aws_route53_record" "voting_alb" {
  name    = local.voting_domain_name
  type    = "A"
  zone_id = data.aws_route53_zone.online_ntnu_no.zone_id

  alias {
    name                   = data.aws_lb.evergreen_gateway.dns_name
    zone_id                = data.aws_lb.evergreen_gateway.zone_id
    evaluate_target_health = false
  }
}
