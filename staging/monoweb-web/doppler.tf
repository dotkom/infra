data "doppler_secrets" "monoweb_web" {
  project = "monoweb-web"
  config  = "stg"
}

resource "doppler_secret" "sentry_dsn" {
  project = data.doppler_secrets.monoweb_web.project
  config  = data.doppler_secrets.monoweb_web.config

  name  = "SENTRY_DSN"
  value = sentry_key.monoweb_web.dsn.public
}
