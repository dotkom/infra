terraform {
  backend "s3" {
    bucket = "terraform-monorepo.online.ntnu.no"
    key    = "invoicification-prod.tfstate"
    region = "eu-north-1"
  }

  required_version = "~> 1.7.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.33"
    }
    vercel = {
      source  = "vercel/vercel"
      version = "~> 1.1"
    }
  }
}

provider "aws" {
  region = "eu-north-1"

  default_tags {
    tags = {
      Project     = "invoicification-prod"
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
      Project     = "invoicification-prod"
      Deployment  = "terraform"
      Repository  = "terraform-monorepo"
      Environment = "prod"
    }
  }
}

provider "vercel" {
  team = "dotkom"
}
