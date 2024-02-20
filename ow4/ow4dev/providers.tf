provider "aws" {
  region = "eu-north-1"
  default_tags {
    tags = {
      Terraform = true
      Project   = "ow4dev"
    }
  }
}

provider "vault" {
  address = "https://vault.online.ntnu.no:8200"
}

provider "postgresql" {
  scheme    = "awspostgres"
  host      = "main-db.cxliesrki50e.eu-north-1.rds.amazonaws.com"
  username  = "atlantis"
  port      = 5432
  superuser = false
}

provider "github" {
  owner = "dotkom"
}
