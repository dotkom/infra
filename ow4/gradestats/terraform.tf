terraform {
  backend "s3" {
    bucket         = "terraform-state.dotkom"
    key            = "applications/gradestats"
    region         = "eu-north-1"
    dynamodb_table = "terraform-lock"
  }
  required_providers {
    postgresql = {
      source = "cyrilgdn/postgresql"
    }
  }
}
