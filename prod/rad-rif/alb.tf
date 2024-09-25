resource "aws_lb_target_group" "rif" {
  name        = "monoweb-prod-rif"
  port        = 3000
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = data.aws_vpc.evergreen.id

  deregistration_delay = 0

  health_check {
    path = "/"
  }
}

resource "aws_lb_listener_rule" "rif" {
  listener_arn = data.aws_lb_listener.gateway.arn
  priority     = 1100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.rif.arn
  }

  condition {
    host_header {
      values = [local.rif_domain_name]
    }
  }
}

resource "aws_lb_listener_certificate" "rif" {
  certificate_arn = module.rif_certificate.certificate_arn
  listener_arn    = data.aws_lb_listener.gateway.arn
}
