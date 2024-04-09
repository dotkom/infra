# http
module "api_gateway_http" {
  source = "../../modules/aws-api-gateway"

  domain          = local.gateway_domain_name_http
  zone_id         = data.aws_route53_zone.online_ntnu_no.zone_id
  certificate_arn = module.api_gateway_domain_certificate_http.certificate_arn
  allow_origins = ["*"]
}

resource "aws_apigatewayv2_integration" "lambda_integration_http" {
  api_id                 = module.api_gateway_http.api_gateway_id
  integration_type       = "AWS_PROXY"
  integration_method     = "POST"
  integration_uri        = module.lambda.lambda_invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "lambda_entrypoint_sync" {
  api_id    = module.api_gateway_http.api_gateway_id
  route_key = "$default"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration_http.id}"
}

# websocket
module "api_gateway_ws" {
  source = "../../modules/aws-websocket-api-gateway"

  domain          = local.gateway_domain_name_ws
  zone_id         = data.aws_route53_zone.online_ntnu_no.zone_id
  certificate_arn = module.api_gateway_domain_certificate_ws.certificate_arn
}

resource "aws_apigatewayv2_integration" "lambda_integration_ws" {
  api_id                 = module.api_gateway_ws.api_gateway_id
  integration_type       = "AWS_PROXY"
  integration_uri        = module.lambda.lambda_invoke_arn
}

resource "aws_apigatewayv2_route" "default" {
  api_id    = module.api_gateway_ws.api_gateway_id
  route_key = "$default"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration_ws.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = module.api_gateway_ws.api_gateway_id
  name        = "$default"
  deployment_id = aws_apigatewayv2_deployment.websocket_deploy.id
}

resource "aws_apigatewayv2_deployment" "websocket_deploy" {
  api_id = module.api_gateway_ws.api_gateway_id

  lifecycle {
    create_before_destroy = true
  }

  triggers = {
    redeployment = sha1(jsonencode([
      aws_apigatewayv2_integration.lambda_integration_ws,
      aws_apigatewayv2_route.default,
    ]))
  }
}

resource "aws_apigatewayv2_api_mapping" "this" {
  api_id      = module.api_gateway_ws.api_gateway_id
  domain_name = local.gateway_domain_name_ws
  stage       = aws_apigatewayv2_stage.default.id
}