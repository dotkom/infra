module "brevduen_ci" {
  source = "../../modules/github-actions-iam"

  role_name = "MonowebStagingBrevduenCIRole"
  repository_scope = [
    "repo:dotkom/monoweb:*"
  ]
}

data "aws_iam_policy_document" "brevduen_ci_role" {
  source_policy_documents = [
    module.server_ecr_image.deployment_permission_set.json,
    module.brevduen_evergreen_service.deployment_permission_set.json,
  ]
}

resource "aws_iam_policy" "brevduen_ci_role" {
  name   = "MonowebStagingBrevduenCIPolicy"
  policy = data.aws_iam_policy_document.brevduen_ci_role.json
}

resource "aws_iam_role_policy_attachment" "brevduen_ci_role" {
  policy_arn = aws_iam_policy.brevduen_ci_role.arn
  role       = module.brevduen_ci.role.name
}
