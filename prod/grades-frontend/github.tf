module "frontend_ci" {
  source = "../../modules/github-actions-iam"

  role_name = "grades-prd-frontend-ci-role"
  repository_scope = [
    "repo:dotkom/monoweb:*"
  ]
}

data "aws_iam_policy_document" "frontend_ci_role" {
  source_policy_documents = [
    module.server_ecr_image.deployment_permission_set.json,
    module.frontend_evergreen_service.deployment_permission_set.json,
  ]
}

resource "aws_iam_policy" "frontend_ci_role" {
  name   = "grades-prd-frontend-ci-policy"
  policy = data.aws_iam_policy_document.frontend_ci_role.json
}

resource "aws_iam_role_policy_attachment" "frontend_ci_role" {
  policy_arn = aws_iam_policy.frontend_ci_role.arn
  role       = module.frontend_ci.role.name
}
