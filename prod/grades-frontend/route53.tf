locals {
  frontend_domain_name = "grades.no"
}

data "aws_route53_zone" "grades_no" {
  name = "grades.no"
}

data "aws_lb" "evergreen_gateway" {
  name = "evergreen-prod-gateway"
}

data "aws_lb_listener" "https" {
  load_balancer_arn = data.aws_lb.evergreen_gateway.arn
  port              = 443
}

resource "aws_route53_record" "frontend_alb" {
  name    = local.frontend_domain_name
  type    = "A"
  zone_id = data.aws_route53_zone.grades_no.zone_id

  allow_overwrite = true

  alias {
    name                   = data.aws_lb.evergreen_gateway.dns_name
    zone_id                = data.aws_lb.evergreen_gateway.zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "frontend_www_alb" {
  name    = "www.${local.frontend_domain_name}"
  type    = "A"
  zone_id = data.aws_route53_zone.grades_no.zone_id

  allow_overwrite = true

  alias {
    name                   = data.aws_lb.evergreen_gateway.dns_name
    zone_id                = data.aws_lb.evergreen_gateway.zone_id
    evaluate_target_health = false
  }
}
