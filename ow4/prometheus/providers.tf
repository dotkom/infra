provider "aws" {
  region = "eu-north-1"
  default_tags {
    tags = {
      Terraform = true
      Project   = "Prometheus"
    }
  }
}

provider "nomad" {
  address = "https://nomad.online.ntnu.no:4646"
  region  = "global"
}

provider "consul" {
  scheme     = "https"
  address    = "consul.online.ntnu.no:8501"
  datacenter = "aws-eu-north-1"
}

provider "vault" {
  address = "https://vault.online.ntnu.no:8200"
}
