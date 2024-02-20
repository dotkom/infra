provider "aws" {
  region = "eu-north-1"

  default_tags {
    tags = {
      Terraform = true
      Project   = "Nomad"
    }

  }
}

provider "consul" {
  scheme     = "https"
  address    = "consul.online.ntnu.no:8501"
  datacenter = "aws-eu-north-1"
}

