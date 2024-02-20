terraform {
  backend "s3" {
    bucket         = "terraform-state.dotkom"
    key            = "vault-deployment"
    region         = "eu-north-1"
    dynamodb_table = "terraform-lock"
  }
  required_providers {
    postgresql = {
      source = "cyrilgdn/postgresql"
    }
  }
}