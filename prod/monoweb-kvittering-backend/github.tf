module "kvittering_backend_ci" {
  source = "../../modules/github-actions-iam"

  role_name = "monoweb-prod-kvittering-backend-ci-role"
  repository_scope = [
    "repo:dotkom/monoweb:*"
  ]
}

data "aws_iam_policy_document" "kvittering_backend_ci_role" {
  source_policy_documents = [
    module.server_ecr_image.deployment_permission_set.json,
    module.evergreen_service.deployment_permission_set.json,
  ]
}

resource "aws_iam_policy" "kvittering_backend_ci_role" {
  name   = "monoweb-prod-kvittering-backend-ci-policy"
  policy = data.aws_iam_policy_document.kvittering_backend_ci_role.json
}

resource "aws_iam_role_policy_attachment" "kvittering_backend_ci_role" {
  policy_arn = aws_iam_policy.kvittering_backend_ci_role.arn
  role       = module.kvittering_backend_ci.role.name
}
