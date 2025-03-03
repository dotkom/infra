module "rpc_ci" {
  source = "../../modules/github-actions-iam"

  role_name = "MonowebProdRPCCIRole"
  repository_scope = [
    "repo:dotkom/monoweb:*"
  ]
}

data "aws_iam_policy_document" "rpc_ci_role" {
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
    ]
    effect = "Allow"
    resources = [
      module.server_ecr_image.ecr_repository_arn
    ]
  }
}

resource "aws_iam_policy" "rpc_ci_role" {
  name   = "MonowebProdRPCCIPolicy"
  policy = data.aws_iam_policy_document.rpc_ci_role.json
}

resource "aws_iam_role_policy_attachment" "rpc_ci_role" {
  policy_arn = aws_iam_policy.rpc_ci_role.arn
  role       = module.rpc_ci.role.name
}

