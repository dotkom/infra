data "aws_iam_policy_document" "ses_send_email" {
  statement {
    sid       = "GatewayEmailSendSES"
    effect    = "Allow"
    actions   = ["ses:SendEmail"]
    resources = ["*"]
  }
}
