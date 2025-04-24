module "ci" {
  source = "../../modules/github-actions-iam"

  role_name = "monoweb-stg-invoicification-ci-role"
  repository_scope = [
    "repo:dotkom/monoweb:*"
  ]
}

data "aws_iam_policy_document" "ci_role" {
  source_policy_documents = [
    module.server_image.deployment_permission_set.json,
    module.invoicification_evergreen_service.deployment_permission_set.json,
  ]
}

resource "aws_iam_policy" "ci_role" {
  name   = "monoweb-stg-invoicification-ci-policy"
  policy = data.aws_iam_policy_document.ci_role.json
}

resource "aws_iam_role_policy_attachment" "ci_role" {
  policy_arn = aws_iam_policy.ci_role.arn
  role       = module.ci.role.name
}
