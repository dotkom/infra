module "server_image" {
  source = "../../modules/aws-ecr-repository"

  ecr_repository_name = "monoweb/staging/invoicification"
}

data "aws_ecr_image" "invoicification" {
  repository_name = module.server_image.ecr_repository_name
  most_recent     = true
}
