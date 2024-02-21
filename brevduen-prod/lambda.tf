module "email_lambda" {
  source = "../modules/aws-docker-lambda"

  ecr_repository_name = "brevduen-prod"
  function_name       = "brevduen-prod"
  execution_role_name = "BrevduenProdLambdaExecutionRole"
  iam_inline_policies = [
    {
      name   = "SESSendEmail"
      policy = data.aws_iam_policy_document.ses_send_email.json
    }
  ]
  environment_variables = {
    EMAIL_TOKEN = data.aws_secretsmanager_secret_version.email_token.secret_string
  }
}

resource "aws_lambda_permission" "email_gateway" {
  statement_id  = "APIGatewayExecuteLambda"
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  function_name = module.email_lambda.lambda_name
  source_arn    = "${module.api_gateway.api_gateway_execution_arn}/*/*"
}
