module "kvittering_frontend_ci" {
  source = "../../modules/github-actions-iam"

  role_name = "MonowebProdKvitteringFrontendCIRole"
  repository_scope = [
    "repo:dotkom/monoweb:*"
  ]
}

data "aws_iam_policy_document" "kvittering_frontend_ci_role" {
  statement {
    actions = [
      "s3:PutObject",
      "cloudfront:CreateInvalidation",
    ]
    effect = "Allow"
    resources = [
      "*"
    ]
  }
}

resource "aws_iam_policy" "kvittering_frontend_ci_role" {
  name   = "MonowebProdKvitteringFrontendCIPolicy"
  policy = data.aws_iam_policy_document.kvittering_frontend_ci_role.json
}

resource "aws_iam_role_policy_attachment" "kvittering_frontend_ci_role" {
  policy_arn = aws_iam_policy.kvittering_frontend_ci_role.arn
  role       = module.kvittering_frontend_ci.role.name
}
