provider "aws" {
  region = "eu-north-1"

  default_tags {
    tags = {
      Terraform = true
      Project   = "Vault deployment"
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

provider "consul" {
  scheme     = "https"
  address    = "consul.online.ntnu.no:8501"
  datacenter = "aws-eu-north-1"
}
