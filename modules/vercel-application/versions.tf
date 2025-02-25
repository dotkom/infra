terraform {
  required_version = "~> 1.9.6"

  required_providers {
    vercel = {
      source  = "vercel/vercel"
      version = "~> 2.9"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.68"
    }
  }
}
