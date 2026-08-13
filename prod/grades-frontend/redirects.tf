resource "aws_lb_listener_rule" "www_redirect" {
  listener_arn = data.aws_lb_listener.https.arn
  priority     = 1099

  action {
    type = "redirect"
    redirect {
      status_code = "HTTP_301"
      protocol    = "HTTPS"
      port        = 443
      host        = local.frontend_domain_name
      path        = "/#{path}"
      query       = "#{query}"
    }
  }

  condition {
    host_header {
      values = ["www.${local.frontend_domain_name}"]
    }
  }
}

resource "aws_lb_listener_certificate" "www" {
  certificate_arn = module.frontend_www_domain_certificate.certificate_arn
  listener_arn    = data.aws_lb_listener.https.arn
}
