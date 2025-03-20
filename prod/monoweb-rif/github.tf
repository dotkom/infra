module "rif_ci" {
  source = "../../modules/github-actions-iam"

  role_name = "MonowebProdRifCIRole"
  repository_scope = [
    "repo:dotkom/monoweb:*"
  ]
}

data "aws_iam_policy_document" "rif_ci_role" {
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
      module.rif_ecr_image.ecr_repository_arn
    ]
  }
}

resource "aws_iam_policy" "rif_ci_role" {
  name   = "MonowebProdRifCIPolicy"
  policy = data.aws_iam_policy_document.rif_ci_role.json
}

resource "aws_iam_role_policy_attachment" "rif_ci_role" {
  policy_arn = aws_iam_policy.rif_ci_role.arn
  role       = module.rif_ci.role.name
}
