module "server_ecr_image" {
  source = "../../modules/aws-ecr-repository"

  ecr_repository_name = "grades/prd/backend"
}

data "aws_ecr_image" "backend" {
  repository_name = module.server_ecr_image.ecr_repository_name
  most_recent     = true
}
