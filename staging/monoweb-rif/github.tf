module "rif_ci" {
  source = "../../modules/github-actions-iam"

  role_name = "MonowebStagingRifCIRole"
  repository_scope = [
    "repo:dotkom/monoweb:*"
  ]
}

data "aws_iam_policy_document" "rif_ci_role" {
  source_policy_documents = [
    module.rif_ecr_image.deployment_permission_set.json,
    module.rif_evergreen_service.deployment_permission_set.json,
  ]
}

resource "aws_iam_policy" "rif_ci_role" {
  name   = "MonowebStagingRifCIPolicy"
  policy = data.aws_iam_policy_document.rif_ci_role.json
}

resource "aws_iam_role_policy_attachment" "rif_ci_role" {
  policy_arn = aws_iam_policy.rif_ci_role.arn
  role       = module.rif_ci.role.name
}
