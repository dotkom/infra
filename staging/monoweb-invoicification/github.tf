module "ci" {
  source = "../../modules/github-actions-iam"

  role_name = "MonowebStagingInvoicificationCIRole"
  repository_scope = [
    "repo:dotkom/monoweb:*"
  ]
}

data "aws_iam_policy_document" "ci_role" {
  statement {
    actions   = ["ecr:GetAuthorizationToken"]
    effect    = "Allow"
    resources = ["*"]
  }
  statement {
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart",
      "ecr:BatchGetImage"
    ]
    effect = "Allow"
    resources = [
      module.server_image.ecr_repository_arn
    ]
  }
}

resource "aws_iam_policy" "ci_role" {
  name   = "MonowebStagingInvoicificationCIPolicy"
  policy = data.aws_iam_policy_document.ci_role.json
}

resource "aws_iam_role_policy_attachment" "ci_role" {
  policy_arn = aws_iam_policy.ci_role.arn
  role       = module.ci.role.name
}
