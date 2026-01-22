terraform {
  required_version = "~> 1.14.0"

  required_providers {
    vercel = {
      source  = "vercel/vercel"
      version = "~> 4.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.13"
    }
  }
}
