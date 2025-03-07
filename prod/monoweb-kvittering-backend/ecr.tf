module "server_ecr_image" {
  source = "../../modules/aws-ecr-repository"

  ecr_repository_name = "monoweb/prod/${local.project_name}"
}

data "aws_ecr_image" "this" {
  repository_name = module.server_ecr_image.ecr_repository_name
  most_recent     = true
}
