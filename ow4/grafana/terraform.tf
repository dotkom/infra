terraform {
  backend "s3" {
    bucket         = "terraform-state.dotkom"
    key            = "applications/grafana"
    region         = "eu-north-1"
    dynamodb_table = "terraform-lock"
  }

  required_providers {
    postgresql = {
      source = "cyrilgdn/postgresql"
    }
  }
}
