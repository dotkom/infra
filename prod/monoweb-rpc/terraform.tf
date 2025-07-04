terraform {
  backend "s3" {
    bucket = "terraform-monorepo.online.ntnu.no"
    key    = "prod/monoweb-rpc.tfstate"
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
    grafana = {
      source  = "grafana/grafana"
      version = "~> 3.25.6"
    }
  }
}

provider "aws" {
  region = "eu-north-1"

  default_tags {
    tags = {
      Project     = "rpc-prod"
      Deployment  = "terraform"
      Repository  = "terraform-monorepo"
      Environment = "prd"
    }
  }
}

provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"

  default_tags {
    tags = {
      Project     = "rpc-prod"
      Deployment  = "terraform"
      Repository  = "terraform-monorepo"
      Environment = "prod"
    }
  }
}

variable "DOPPLER_TOKEN_ALL" {
  description = "TF Variable for the doppler service token"
  type        = string
}

provider "doppler" {
  doppler_token = var.DOPPLER_TOKEN_ALL
}

provider "sentry" {}

variable "GRAFANA_SERVICE_ACCOUNT_TOKEN" {
  description = "Grafana service account token"
  type        = string
}

variable "GRAFANA_MASTER_POLICY_TOKEN" {
  description = "Grafana policy token"
  type        = string
}

provider "grafana" {
  url                       = "https://dotkomonline.grafana.net"
  auth                      = var.GRAFANA_SERVICE_ACCOUNT_TOKEN
  cloud_access_policy_token = var.GRAFANA_MASTER_POLICY_TOKEN
}
