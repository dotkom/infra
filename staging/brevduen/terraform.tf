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
  }
}

provider "aws" {
  region = "eu-north-1"

  default_tags {
    tags = {
      Project     = "brevduen-staging"
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
      Project     = "brevduen-staging"
      Deployment  = "terraform"
      Repository  = "terraform-monorepo"
      Environment = "staging"
    }
  }
}
