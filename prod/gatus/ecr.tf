module "ecr_image" {
  source = "../../modules/aws-ecr-repository"

  ecr_repository_name = "monoweb/prod/gatus"
}

data "aws_ecr_image" "gatus" {
  repository_name = module.ecr_image.ecr_repository_name
  most_recent     = true
}
