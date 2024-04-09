terraform {
  backend "s3" {
    bucket = "terraform-monorepo.online.ntnu.no"
    key    = "batman-staging.tfstate"
    region = "eu-north-1"
  }

  required_version = "~> 1.7.3"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.23.0"
    }
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

provider "google" {
  project         = var.gcloud_project_id
  request_timeout = "60s"
  region = "europe-north1"
  zone = "europe-north1-a"
}

provider "aws" {
  region = "eu-north-1"

  default_tags {
    tags = {
      Project     = "batman-staging"
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
      Project     = "batman-staging"
      Deployment  = "terraform"
      Repository  = "terraform-monorepo"
      Environment = "staging"
    }
  }
}


variable "DOPPLER_TOKEN_BATMAN" {
  description = "TF Variable for the batman doppler token"
  type        = string
}

provider "doppler" {
  doppler_token = var.DOPPLER_TOKEN_BATMAN
}