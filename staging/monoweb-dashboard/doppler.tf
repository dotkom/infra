data "doppler_secrets" "monoweb_dashboard" {
  project = "monoweb-dashboard"
  config  = "stg"
}

resource "doppler_secret" "sentry_dsn" {
  project = data.doppler_secrets.monoweb_dashboard.project
  config  = data.doppler_secrets.monoweb_dashboard.config

  name  = "SENTRY_DSN"
  value = sentry_key.monoweb_dashboard.dsn.public
}

resource "doppler_secret" "next_public_sentry_dsn" {
  project = data.doppler_secrets.monoweb_dashboard.project
  config  = data.doppler_secrets.monoweb_dashboard.config

  name  = "NEXT_PUBLIC_SENTRY_DSN"
  value = sentry_key.monoweb_dashboard.dsn.public
}
