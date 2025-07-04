module "grafana_access_policy" {
  source = "../../modules/grafana-access-policy"

  grafana_region = "prod-eu-north-0"
  policy_name    = "monoweb-prd-web"
}

resource "doppler_secret" "otlp_headers" {
  config  = data.doppler_secrets.monoweb_web.config
  project = data.doppler_secrets.monoweb_web.project

  name  = "OTEL_EXPORTER_OTLP_HEADERS"
  value = "Authorization=Basic ${base64encode("${module.grafana_access_policy.grafana_stack}:${module.grafana_access_policy.token}")}"
}

resource "doppler_secret" "otlp_endpoint" {
  config  = data.doppler_secrets.monoweb_web.config
  project = data.doppler_secrets.monoweb_web.project

  name  = "OTEL_EXPORTER_OTLP_ENDPOINT"
  value = "https://otlp-gateway-prod-eu-north-0.grafana.net/otlp"
}

resource "doppler_secret" "otlp_protocol" {
  config  = data.doppler_secrets.monoweb_web.config
  project = data.doppler_secrets.monoweb_web.project

  name  = "OTEL_EXPORTER_OTLP_PROTOCOL"
  value = "http/protobuf"
}
