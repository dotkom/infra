module "server_ecr_image" {
  source = "../../modules/aws-ecr-repository"

  ecr_repository_name = "monoweb/stg/web"
}

data "aws_ecr_image" "web" {
  repository_name = module.server_ecr_image.ecr_repository_name
  most_recent     = true
}
