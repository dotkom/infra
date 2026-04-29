data "doppler_secrets" "grades_frontend" {
  project = "grades-frontend"
  config  = "prd"
}

resource "doppler_secret" "sentry_dsn" {
  project = data.doppler_secrets.grades_frontend.project
  config  = data.doppler_secrets.grades_frontend.config

  name  = "SENTRY_DSN"
  value = sentry_key.grades_frontend.dsn.public
}
