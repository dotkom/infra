terraform {
  backend "local" {
    path = "bootstrap.tfstate"
  }

  required_version = "~> 1.7.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.33"
    }
  }
}

provider "aws" {
  region = "eu-north-1"

  default_tags {
    tags = {
      Project = "terraform-monorepo-bootstrap"
    }
  }
}