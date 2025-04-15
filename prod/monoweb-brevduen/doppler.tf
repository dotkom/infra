data "doppler_secrets" "monoweb_brevduen" {
  project = "monoweb-brevduen"
  config  = "prod"
}

resource "doppler_secret" "monoweb_brevduen" {
  project = data.doppler_secrets.monoweb_brevduen.project
  config  = data.doppler_secrets.monoweb_brevduen.config

  name  = "SENTRY_DSN"
  value = sentry_key.monoweb_brevduen.dsn.public
}
