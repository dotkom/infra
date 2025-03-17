terraform {
  backend "s3" {
    bucket = "terraform-monorepo.online.ntnu.no"
    key    = "staging/monoweb-rif.tfstate"
    region = "eu-north-1"
  }

  required_version = "~> 1.9.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.68"
    }
    doppler = {
      source  = "DopplerHQ/doppler"
      version = "~> 1.11"
    }
  }
}

provider "aws" {
  region = "eu-north-1"

  default_tags {
    tags = {
      Project     = "rad-rif-staging"
      Deployment  = "terraform"
      Repository  = "terraform-monorepo"
      Environment = "staging"
    }
  }
}

provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"

  default_tags {
    tags = {
      Project     = "rad-rif-staging"
      Deployment  = "terraform"
      Repository  = "terraform-monorepo"
      Environment = "staging"
    }
  }
}

variable "DOPPLER_TOKEN_ALL" {
  type = string
}

provider "doppler" {
  doppler_token = var.DOPPLER_TOKEN_ALL
}
