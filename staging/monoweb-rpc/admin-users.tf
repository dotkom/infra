resource "doppler_secret" "admin_users" {
  config  = data.doppler_secrets.monoweb_rpc.config
  project = data.doppler_secrets.monoweb_rpc.project

  name  = "ADMIN_USERS"
  value = "*"
}
