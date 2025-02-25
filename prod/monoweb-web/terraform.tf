terraform {
  backend "s3" {
    bucket = "terraform-monorepo.online.ntnu.no"
    key    = "prod/monoweb-web.tfstate"
    region = "eu-north-1"
  }

  required_version = "~> 1.9.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.68"
    }
    vercel = {
      source  = "vercel/vercel"
      version = "~> 2.9"
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
      Project     = "web-prod"
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
      Project     = "web-prod"
      Deployment  = "terraform"
      Repository  = "terraform-monorepo"
      Environment = "prod"
    }
  }
}

provider "vercel" {
  team = "dotkom"
}

variable "DOPPLER_TOKEN_WEB_STAGING" {
  description = "TF Variable for web staging doppler token"
  type        = string
}

provider "doppler" {
  doppler_token = var.DOPPLER_TOKEN_WEB_STAGING
}
