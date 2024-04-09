resource "aws_apigatewayv2_api" "this" {
  name          = var.domain
  protocol_type = "WEBSOCKET"
  route_selection_expression = "$request.body.action"
  description   = "Websocket API Gateway for ${var.domain}"
  tags = local.tags_all
}

resource "aws_apigatewayv2_domain_name" "this" {
  domain_name = var.domain
  domain_name_configuration {
    certificate_arn = var.certificate_arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }

  tags = local.tags_all
}

