locals {
  backend_domain_name = "api.grades.no"
}

data "aws_route53_zone" "grades_no" {
  name = "grades.no"
}

data "aws_lb" "evergreen_gateway" {
  name = "evergreen-prod-gateway"
}

resource "aws_route53_record" "backend_alb" {
  name    = local.backend_domain_name
  type    = "A"
  zone_id = data.aws_route53_zone.grades_no.zone_id

  allow_overwrite = true

  alias {
    name                   = data.aws_lb.evergreen_gateway.dns_name
    zone_id                = data.aws_lb.evergreen_gateway.zone_id
    evaluate_target_health = false
  }
}
