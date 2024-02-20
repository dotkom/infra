terraform {
  backend "s3" {
    bucket         = "terraform-state.dotkom"
    key            = "applications/nomad-ebs-volume-plugin"
    region         = "eu-north-1"
    dynamodb_table = "terraform-lock"
  }
}
