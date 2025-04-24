locals {
  // TODO: Learn how to avoid this hardcoding, yet handle perms in the Cloud Access Token correctly
  grafana_cloud_stack = "1202339"
}

resource "grafana_cloud_access_policy" "grafana" {
  region       = "prod-eu-north-0"
  name         = "monoweb-prd-dashboard"
  display_name = "Grafana Cloud Access for Monoweb Dashboard"

  scopes = [
    "metrics:write",
    "logs:write",
    "traces:write",
    "alerts:write",
  ]

  conditions {
    allowed_subnets = []
  }

  realm {
    type       = "stack"
    identifier = local.grafana_cloud_stack

    label_policy {
      selector = "{namespace=\"default\"}"
    }
  }
}

resource "grafana_cloud_access_policy_token" "grafana" {
  region           = "prod-eu-north-0"
  access_policy_id = grafana_cloud_access_policy.grafana.policy_id
  name             = "monoweb-prd-dashboard"
  display_name     = "Grafana Cloud Access for Monoweb Dashboard"
}

resource "doppler_secret" "otlp_headers" {
  config  = data.doppler_secrets.monoweb_dashboard.config
  project = data.doppler_secrets.monoweb_dashboard.project

  name  = "OTEL_EXPORTER_OTLP_HEADERS"
  value = "Authorization=Basic ${base64encode("${local.grafana_cloud_stack}:${grafana_cloud_access_policy_token.grafana.token}")}"
}

resource "doppler_secret" "otlp_endpoint" {
  config  = data.doppler_secrets.monoweb_dashboard.config
  project = data.doppler_secrets.monoweb_dashboard.project

  name  = "OTEL_EXPORTER_OTLP_ENDPOINT"
  value = "https://otlp-gateway-prod-eu-north-0.grafana.net/otlp"
}

resource "doppler_secret" "otlp_protocol" {
  config  = data.doppler_secrets.monoweb_dashboard.config
  project = data.doppler_secrets.monoweb_dashboard.project

  name  = "OTEL_EXPORTER_OTLP_PROTOCOL"
  value = "http/protobuf"
}
