terraform {
  backend "s3" {
    bucket = "terraform-monorepo.online.ntnu.no"
    key    = "prod/grafana.tfstate"
    region = "eu-north-1"
  }

  required_version = "~> 1.14.0"

  required_providers {
    grafana = {
      source  = "grafana/grafana"
      version = "~> 4.0"
    }
    doppler = {
      source  = "DopplerHQ/doppler"
      version = "~> 1.11"
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

variable "GRAFANA_SERVICE_ACCOUNT_TOKEN" {
  description = "Grafana service account token"
  type        = string
}

provider "grafana" {
  url  = "https://dotkomonline.grafana.net"
  auth = var.GRAFANA_SERVICE_ACCOUNT_TOKEN
}
