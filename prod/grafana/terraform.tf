terraform {
  backend "s3" {
    bucket = "terraform-monorepo.online.ntnu.no"
    key    = "prod/grafana.tfstate"
    region = "eu-north-1"
  }

  required_version = "~> 1.9.6"

  required_providers {
    grafana = {
      source  = "grafana/grafana"
      version = "~> 3.22"
    }
  }
}

variable "GRAFANA_SERVICE_ACCOUNT_TOKEN" {
  description = "Grafana service account token"
  type        = string
}

provider "grafana" {
  url  = "https://dotkomonline.grafana.net"
  auth = var.GRAFANA_SERVICE_ACCOUNT_TOKEN
}
