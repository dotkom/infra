module "ecr_image" {
  source = "../../modules/aws-ecr-repository"

  ecr_repository_name = "monoweb/prd/gatus"
}

data "aws_ecr_image" "gatus" {
  repository_name = "grades/stg/server"
  most_recent     = true
}
