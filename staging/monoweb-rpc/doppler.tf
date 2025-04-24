data "doppler_secrets" "monoweb_rpc" {
  project = "monoweb-rpc"
  config  = "stg"
}

resource "doppler_secret" "sentry_dsn" {
  project = data.doppler_secrets.monoweb_rpc.project
  config  = data.doppler_secrets.monoweb_rpc.config

  name  = "SENTRY_DSN"
  value = sentry_key.monoweb_rpc.dsn.public
}
