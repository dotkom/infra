module "server_ecr_image" {
  source = "../../modules/aws-ecr-repository"

  ecr_repository_name = "grades/prod/server"
}

data "aws_ecr_image" "server" {
  repository_name = "grades/stg/server"
  most_recent     = true
}

module "web_ecr_image" {
  source = "../../modules/aws-ecr-repository"

  ecr_repository_name = "grades/prod/web"
}

data "aws_ecr_image" "web" {
  repository_name = "grades/stg/server"
  most_recent     = true
}
