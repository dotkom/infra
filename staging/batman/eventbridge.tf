# run watch function every day at 12:00 UTC

resource "aws_cloudwatch_event_rule" "this" {
  name        = "batman-gmail-watch-staging"
  description = "Keep gmail subscription alive"

  schedule_expression = "cron(37 9 * * ? *)"
}

resource "aws_cloudwatch_event_target" "lambda" {
  target_id = "batman-gmail-watch"
  rule      = aws_cloudwatch_event_rule.this.name
  arn       = module.lambda.lambda_arn
  input = jsonencode({
        "type"  : "eventbridge",
        "route" : "gmail-watch"
    })
}

data "aws_iam_policy_document" "execute_lambda" {
  statement {
    effect  = "Allow"
    actions = ["lambda:InvokeFunction"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    resources = [module.lambda.lambda_arn]
  }
}