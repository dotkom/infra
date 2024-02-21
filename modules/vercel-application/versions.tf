terraform {
  required_version = "~> 1.7.3"

  required_providers {
    vercel = {
      source  = "vercel/vercel"
      version = "~> 1.1"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.33"
    }
  }
}
