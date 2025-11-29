terraform {
  required_version = "~> 1.13.0"

  required_providers {
    vercel = {
      source  = "vercel/vercel"
      version = "~> 2.9"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.13"
    }
  }
}
