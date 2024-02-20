terraform {
  backend "s3" {
    bucket         = "terraform-state.dotkom"
    key            = "applications/traefik"
    region         = "eu-north-1"
    dynamodb_table = "terraform-lock"
  }
}
