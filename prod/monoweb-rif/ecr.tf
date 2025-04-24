module "rif_ecr_image" {
  source = "../../modules/aws-ecr-repository"

  ecr_repository_name = "monoweb/prd/rif"
}

data "aws_ecr_image" "rif" {
  repository_name = module.rif_ecr_image.ecr_repository_name
  most_recent     = true
}
