terraform {
  backend "s3" {
    bucket = "terraform-monorepo.online.ntnu.no"
    key    = "pizzapicker-prod.tfstate"
    region = "eu-north-1"
  }

  required_version = "~> 1.7.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.33"
    }
    doppler = {
      source  = "DopplerHQ/doppler"
      version = "~> 1.3.0"
    }
  }
}

provider "aws" {
  region = "eu-north-1"

  default_tags {
    tags = {
      Project     = "pizzapicker-prod"
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
      Project     = "pizzapicker-prod"
      Deployment  = "terraform"
      Repository  = "terraform-monorepo"
      Environment = "prod"
    }
  }
}

variable "DOPPLER_TOKEN_PIZZAPICKER" {
  description = "TF Variable for the pizzapicker doppler token"
  type        = string
}

provider "doppler" {
  doppler_token = var.DOPPLER_TOKEN_PIZZAPICKER
}
