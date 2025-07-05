module "server_ecr_image" {
  source = "../../modules/aws-ecr-repository"

  ecr_repository_name = "voting/prod/backend"
}
