terraform {
  backend "s3" {
    bucket = "terraform-monorepo.online.ntnu.no"
    key    = "prod/monoweb-kvittering-backend.tfstate"
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
    sentry = {
      source  = "jianyuan/sentry"
      version = "0.14.3"
    }
  }
}

provider "aws" {
  region = "eu-north-1"

  default_tags {
    tags = {
      Project     = "kvittering-backend-prod"
      Deployment  = "terraform"
      Repository  = "terraform-monorepo"
      Environment = "prod"
    }
  }
}

provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"

  default_tags {
    tags = {
      Project     = "kvittering-staging"
      Deployment  = "terraform"
      Repository  = "terraform-monorepo"
      Environment = "staging"
    }
  }
}

variable "DOPPLER_TOKEN_MONOWEB_KVITTERING_BACKEND" {
  description = "TF Variable for the monoweb-kvittering-backend doppler token"
  type        = string
}

provider "doppler" {
  doppler_token = var.DOPPLER_TOKEN_MONOWEB_KVITTERING_BACKEND
}

provider "sentry" {}
