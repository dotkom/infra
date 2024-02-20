data "aws_caller_identity" "current" {}

# TODO: this should be a resource but using Atlantis import is kinda wonky
data "aws_ecr_repository" "repo" {
  name = "onlineweb4-zappa"
}
