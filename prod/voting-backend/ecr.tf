module "server_ecr_image" {
  source = "../../modules/aws-ecr-repository"

  ecr_repository_name = "voting/prod/backend"
}

# tflint-ignore: terraform_unused_declarations
data "aws_ecr_image" "voting" {
  repository_name = module.server_ecr_image.ecr_repository_name
  most_recent     = true
}
