module "ecr_repository" {
  source = "../../modules/aws-ecr-repository"

  ecr_repository_name = "pizzapicker-prod"
}
