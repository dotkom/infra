module "faktura_redirect" {
  source = "../../modules/aws-acm-certificate"

  domain  = "faktura.online.ntnu.no"
  zone_id = data.aws_route53_zone.online_ntnu_no.zone_id

  providers = {
    aws.regional = aws
  }
}

module "interesse_redirect" {
  source = "../../modules/aws-acm-certificate"

  domain  = "interesse.online.ntnu.no"
  zone_id = data.aws_route53_zone.online_ntnu_no.zone_id

  providers = {
    aws.regional = aws
  }
}

resource "aws_lb_listener_rule" "faktura_redirect" {
  listener_arn = data.aws_lb_listener.https.arn
  action {
    type = "redirect"
    redirect {
      status_code = "HTTP_301"
      protocol    = "HTTPS"
      port        = 443
      host        = "online.ntnu.no"
      path        = "/bedrift/faktura"
    }
  }
  condition {
    host_header {
      values = ["faktura.online.ntnu.no"]
    }
  }
}

resource "aws_lb_listener_rule" "interesse_redirect" {
  listener_arn = data.aws_lb_listener.https.arn
  action {
    type = "redirect"
    redirect {
      status_code = "HTTP_301"
      protocol    = "HTTPS"
      port        = 443
      host        = "online.ntnu.no"
      path        = "/bedrift/interesse"
    }
  }
  condition {
    host_header {
      values = ["interesse.online.ntnu.no"]
    }
  }
}

resource "aws_route53_record" "faktura_redirect" {
  name    = "faktura.online.ntnu.no"
  type    = "A"
  zone_id = data.aws_route53_zone.online_ntnu_no.zone_id
  alias {
    name                   = data.aws_lb.evergreen_gateway.dns_name
    zone_id                = data.aws_lb.evergreen_gateway.zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "interesse_redirect" {
  name    = "interesse.online.ntnu.no"
  type    = "A"
  zone_id = data.aws_route53_zone.online_ntnu_no.zone_id
  alias {
    name                   = data.aws_lb.evergreen_gateway.dns_name
    zone_id                = data.aws_lb.evergreen_gateway.zone_id
    evaluate_target_health = false
  }
}

resource "aws_lb_listener_certificate" "faktura" {
  certificate_arn = module.faktura_redirect.certificate_arn
  listener_arn    = data.aws_lb_listener.https.arn
}

resource "aws_lb_listener_certificate" "interesse" {
  certificate_arn = module.interesse_redirect.certificate_arn
  listener_arn    = data.aws_lb_listener.https.arn
}
