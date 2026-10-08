resource "doppler_secret" "sentry_admin_dsn" {
  project = "monoweb-web"
  config  = "prd"

  name  = "SENTRY_ADMIN_DSN"
  value = sentry_key.monoweb_admin.dsn.public
}
