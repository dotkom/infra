terraform {
  backend "s3" {
    bucket         = "terraform-state.dotkom"
    key            = "ow4dev"
    region         = "eu-north-1"
    dynamodb_table = "terraform-lock"
  }
  required_providers {
    postgresql = {
      source = "cyrilgdn/postgresql"
    }
    github = {
      source  = "integrations/github"
      version = "~> 4.0"
    }
  }
}
