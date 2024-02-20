terraform {
  backend "s3" {
    bucket         = "terraform-state.dotkom"
    key            = "applications/onlineweb-frontend"
    region         = "eu-north-1"
    dynamodb_table = "terraform-lock"
  }

  required_providers {
    vercel = {
      source = "chronark/vercel"
    }
  }
}
