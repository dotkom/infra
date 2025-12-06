terraform {
  required_version = "~> 1.14.0"

  required_providers {
    grafana = {
      source  = "grafana/grafana"
      version = "~> 3.25.6"
    }
  }
}
