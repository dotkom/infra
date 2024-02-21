terraform {
  backend "s3" {
    bucket = "terraform-monorepo.online.ntnu.no"
    key    = "brevduen-staging.tfstate"
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
      Project = "brevduen-staging"
    }
  }
}

provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"

  default_tags {
    tags = {
      Project = "brevduen-staging"
    }
  }
}

variable "DOPPLER_TOKEN_MONOWEB" {
  description = "TF Variable for the doppler token"
  type        = string
}

provider "doppler" {
  doppler_token = var.DOPPLER_TOKEN_MONOWEB
}
