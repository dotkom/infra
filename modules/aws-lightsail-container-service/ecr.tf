moved {
  from = module.gradestats_app_repository
  to   = module.ecr_repository
}

// TODO: Rename and move this
module "ecr_repository" {
  source = "../aws-ecr-repository"

  ecr_repository_name = var.service_name
  tags                = local.tags_all
}

resource "aws_ecr_repository_policy" "pull" {
  policy     = data.aws_iam_policy_document.pull.json
  repository = module.ecr_repository.ecr_repository_name
}
