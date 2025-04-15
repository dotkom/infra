data "doppler_secrets" "invoicification" {
  project = "monoweb-invoicification"
  config  = "staging"
}

resource "doppler_secret" "sentry_dsn" {
  project = data.doppler_secrets.invoicification.project
  config  = data.doppler_secrets.invoicification.config

  name  = "SENTRY_DSN"
  value = sentry_key.monoweb_invoicification.dsn.public
}

resource "doppler_secret" "next_public_sentry_dsn" {
  project = data.doppler_secrets.invoicification.project
  config  = data.doppler_secrets.invoicification.config

  name  = "NEXT_PUBLIC_SENTRY_DSN"
  value = sentry_key.monoweb_invoicification.dsn.public
}
