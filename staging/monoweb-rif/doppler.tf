data "doppler_secrets" "rif" {
  project = "monoweb-rif"
  config  = "stg"
}

resource "doppler_secret" "sentry_dsn" {
  project = data.doppler_secrets.rif.project
  config  = data.doppler_secrets.rif.config

  name  = "SENTRY_DSN"
  value = sentry_key.monoweb_rif.dsn.public
}

resource "doppler_secret" "next_public_sentry_dsn" {
  project = data.doppler_secrets.rif.project
  config  = data.doppler_secrets.rif.config

  name  = "NEXT_PUBLIC_SENTRY_DSN"
  value = sentry_key.monoweb_rif.dsn.public
}
