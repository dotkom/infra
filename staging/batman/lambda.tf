module "lambda" {
  source = "../../modules/aws-docker-lambda"

  ecr_repository_name = "batman-staging"
  function_name       = "batman-staging"
  execution_role_name = "batmanStagingLambdaExecutionRole"
  environment_variables = data.doppler_secrets.batman.map
}

resource "aws_iam_role_policy_attachment" "aws_lambda_execution_role" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonAPIGatewayInvokeFullAccess"
  role       = module.lambda.iam_role
}

resource "aws_iam_policy" "lambda_s3_full_access" {
  name        = "LambdaS3FullAccess"
  path        = "/"
  description = "IAM policy for Lambda to access S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:*",
        ]
        Effect   = "Allow"
        Resource = [
          "${aws_s3_bucket.this.arn}",
          "${aws_s3_bucket.this.arn}/*"
        ]
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_s3_full_access" {
  role       = module.lambda.iam_role
  policy_arn = aws_iam_policy.lambda_s3_full_access.arn
}

resource "aws_lambda_permission" "allow_apigateway" {
  statement_id  = "APIGatewayExecuteLambda"
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  function_name = module.lambda.lambda_name
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda.lambda_name
  principal     = "events.amazonaws.com"
}
