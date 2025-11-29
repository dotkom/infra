terraform {
  required_version = "~> 1.13.0"

  required_providers {
    grafana = {
      source  = "grafana/grafana"
      version = "~> 3.25.6"
    }
  }
}
