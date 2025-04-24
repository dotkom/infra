module "ecr_image" {
  source = "../../modules/aws-ecr-repository"

  ecr_repository_name = "monoweb/prd/invoicification"
}

moved {
  from = module.rif_ecr_image
  to   = module.ecr_image
}

data "aws_ecr_image" "invoicification" {
  repository_name = module.ecr_image.ecr_repository_name
  most_recent     = true
}
