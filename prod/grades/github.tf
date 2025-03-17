module "server_ci" {
  source = "../../modules/github-actions-iam"

  role_name = "GradesProdServerCIRole"
  repository_scope = [
    "repo:dotkom/gradestats:*",
  ]
}

module "web_ci" {
  source = "../../modules/github-actions-iam"

  role_name = "GradesProdWebCIRole"
  repository_scope = [
    "repo:dotkom/gradestats-app:*",
  ]
}

data "aws_iam_policy_document" "web_ci_role" {
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
      "ecr:BatchGetImage",
    ]
    effect = "Allow"
    resources = [
      module.web_ecr_image.ecr_repository_arn
    ]
  }
}

resource "aws_iam_policy" "web_ci_policy" {
  name   = "GradesProdWebCIPolicy"
  policy = data.aws_iam_policy_document.web_ci_role.json
}

resource "aws_iam_role_policy_attachment" "web_ci_role" {
  policy_arn = aws_iam_policy.web_ci_policy.arn
  role       = module.web_ci.role.name
}
