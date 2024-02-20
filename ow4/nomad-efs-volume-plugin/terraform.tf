terraform {
  backend "s3" {
    bucket         = "terraform-state.dotkom"
    key            = "applications/nomad-efs-volume-plugin"
    region         = "eu-north-1"
    dynamodb_table = "terraform-lock"
  }
}
