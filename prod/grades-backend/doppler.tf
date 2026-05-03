data "doppler_secrets" "grades_backend" {
  project = "grades-backend"
  config  = "prd"
}

resource "doppler_secret" "sentry_dsn" {
  project = data.doppler_secrets.grades_backend.project
  config  = data.doppler_secrets.grades_backend.config

  name  = "SENTRY_DSN"
  value = sentry_key.grades_backend.dsn.public
}
