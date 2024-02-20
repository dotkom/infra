terraform {
  backend "s3" {
    bucket         = "terraform-state.dotkom"
    key            = "consul-config"
    region         = "eu-north-1"
    dynamodb_table = "terraform-lock"
  }
}
