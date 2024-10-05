
module "rif_ecr_image" {
  source = "../../modules/aws-ecr-repository"

  ecr_repository_name = "monoweb/prod/invoicification"
}

data "aws_ecr_image" "invoicification" {
  repository_name = module.rif_ecr_image.ecr_repository_name
  most_recent     = true
}
