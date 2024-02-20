terraform {
  backend "s3" {
    bucket         = "terraform-state.dotkom"
    key            = "applications/ow-gtx"
    region         = "eu-north-1"
    dynamodb_table = "terraform-lock"
  }
}
