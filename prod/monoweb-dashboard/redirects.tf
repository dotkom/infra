data "aws_lb_listener" "https" {
  load_balancer_arn = data.aws_lb.evergreen_gateway.arn
  port              = 443
}

resource "aws_lb_listener_rule" "dashboard_redirect" {
  listener_arn = data.aws_lb_listener.https.arn
  priority     = 1601

  action {
    type = "redirect"

    redirect {
      protocol    = "HTTPS"
      port        = "443"
      host        = "online.ntnu.no"
      path        = "/admin/#{path}"
      query       = "#{query}"
      status_code = "HTTP_301"
    }
  }

  condition {
    host_header {
      values = [local.dashboard_domain_name]
    }
  }
}

resource "aws_lb_listener_certificate" "dashboard_redirect" {
  listener_arn    = data.aws_lb_listener.https.arn
  certificate_arn = module.dashboard_domain_certificate.certificate_arn
}

moved {
  from = module.dashboard_evergreen_service.aws_lb_listener_rule.this
  to   = aws_lb_listener_rule.dashboard_redirect
}

moved {
  from = module.dashboard_evergreen_service.aws_lb_listener_certificate.this[0]
  to   = aws_lb_listener_certificate.dashboard_redirect
}
