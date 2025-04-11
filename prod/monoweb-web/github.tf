module "web_ci" {
  source = "../../modules/github-actions-iam"

  role_name = "monoweb-prod-web-ci-role"
  repository_scope = [
    "repo:dotkom/monoweb:*"
  ]
}

data "aws_iam_policy_document" "web_ci_role" {
  source_policy_documents = [
    module.server_ecr_image.deployment_permission_set.json,
    module.web_evergreen_service.deployment_permission_set.json,
  ]
}

resource "aws_iam_policy" "web_ci_role" {
  name   = "monoweb-prod-web-ci-policy"
  policy = data.aws_iam_policy_document.web_ci_role.json
}

resource "aws_iam_role_policy_attachment" "web_ci_role" {
  policy_arn = aws_iam_policy.web_ci_role.arn
  role       = module.web_ci.role.name
}
