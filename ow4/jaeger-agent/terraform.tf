terraform {
  backend "s3" {
    bucket         = "terraform-state.dotkom"
    key            = "applications/jaeger-agent"
    region         = "eu-north-1"
    dynamodb_table = "terraform-lock"
  }
}
