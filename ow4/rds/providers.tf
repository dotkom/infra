provider "aws" {
  region = "eu-north-1"
  default_tags {
    tags = {
      Terraform = true
      Project   = "RDS"
    }
  }
}

provider "vault" {
  address = "https://vault.online.ntnu.no:8200"
}