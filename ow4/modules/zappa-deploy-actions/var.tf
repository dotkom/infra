variable "iam_user_name" {
  type        = string
  description = "Username of generated IAM-user"
}

variable "deploy_bucket_arn" {
  type        = string
  description = "ARN of the bucket the IAM-user should have access to, for deploying static files"
}

variable "github_repository" {
  type        = string
  description = "Name of Github repository to store the secrets in"
}

variable "environment" {
  type        = string
  description = "Name of Github Environment to store secrets in"
}
