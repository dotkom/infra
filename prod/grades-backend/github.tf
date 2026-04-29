module "backend_ci" {
  source = "../../modules/github-actions-iam"

  role_name = "grades-prd-backend-ci-role"
  repository_scope = [
    "repo:dotkom/monoweb:*"
  ]
}

data "aws_iam_policy_document" "backend_ci_role" {
  source_policy_documents = [
    module.server_ecr_image.deployment_permission_set.json,
    module.backend_evergreen_service.deployment_permission_set.json,
  ]
}

resource "aws_iam_policy" "backend_ci_role" {
  name   = "grades-prd-backend-ci-policy"
  policy = data.aws_iam_policy_document.backend_ci_role.json
}

resource "aws_iam_role_policy_attachment" "backend_ci_role" {
  policy_arn = aws_iam_policy.backend_ci_role.arn
  role       = module.backend_ci.role.name
}
