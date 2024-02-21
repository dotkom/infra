module "api_gateway" {
  source = "../modules/aws-api-gateway"

  domain          = local.gateway_domain_name
  zone_id         = data.aws_route53_zone.online_ntnu_no.zone_id
  certificate_arn = module.api_gateway_domain_certificate.certificate_arn
}

resource "aws_apigatewayv2_integration" "lambda" {
  api_id                 = module.api_gateway.api_gateway_id
  integration_type       = "AWS_PROXY"
  integration_method     = "POST"
  integration_uri        = module.email_lambda.lambda_invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "lambda" {
  api_id    = module.api_gateway.api_gateway_id
  route_key = "POST /integrations/email"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}
