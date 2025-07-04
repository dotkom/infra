terraform {
  required_version = "~> 1.9.6"

  required_providers {
    grafana = {
      source  = "grafana/grafana"
      version = "~> 3.25.6"
    }
  }
}
