module "terraform_iam" {
  source = "../modules/github-actions-iam"

  role_name        = "TerraformMonorepoInfraCIRole"
  repository_scope = ["repo:dotkom/terraform-monorepo:*"]
}

data "aws_iam_policy_document" "ci" {
  # State manipulation
  statement {
    actions = [
      "s3:ListObjects"
    ]
    effect = "Allow"
    resources = [
      "arn:aws:s3:::terraform-monorepo.online.ntnu.no"
    ]
  }
  statement {
    actions = [
      "s3:GetObject",
      "s3:PutObject"
    ]
    effect = "Allow"
    resources = [
      "arn:aws:s3:::terraform-monorepo.online.ntnu.no/*"
    ]
  }
  # Select permissions onto resources that can be modified
  statement {
    actions = [
      "ecs:DeleteTaskDefinitions",
      "ecs:DeregisterTaskDefinition",
      "ecs:RegisterTaskDefinition",
      "ecs:RunTask",
      "ecs:StartTask",
      "ecs:StopTask",
      "ecs:UpdateService",
      "ecs:TagResource",
      "iam:PassRole",
    ]
    effect = "Allow"
    resources = [
      "*"
    ]
  }
}

resource "aws_iam_policy" "ci" {
  name   = "TerraformMonorepoInfraCIPolicy"
  policy = data.aws_iam_policy_document.ci.json
}

resource "aws_iam_role_policy_attachment" "ci" {
  policy_arn = aws_iam_policy.ci.arn
  role       = module.terraform_iam.role.name
}

data "aws_iam_policy" "readonly_access" {
  arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "readonly_access" {
  policy_arn = data.aws_iam_policy.readonly_access.arn
  role       = module.terraform_iam.role.name
}

data "github_repository" "terraform_monorepo" {
  name = "terraform-monorepo"
}

data "doppler_secrets" "terraform" {
  project = "terraform"
  config  = "prod"
}

resource "github_actions_secret" "prod_token" {
  secret_name     = "DOPPLER_PROD_SERVICE_TOKEN"
  repository      = data.github_repository.terraform_monorepo.name
  plaintext_value = data.doppler_secrets.terraform.map["GITHUB_ACTIONS_SERVICE_TOKEN"]
}
