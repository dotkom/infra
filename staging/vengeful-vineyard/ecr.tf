module "server_ecr_image" {
  source = "../../modules/aws-ecr-repository"

  ecr_repository_name = "vengeful-vineyard/staging/server"
}

data "aws_ecr_image" "server" {
  repository_name = module.server_ecr_image.ecr_repository_name
  most_recent     = true
}
