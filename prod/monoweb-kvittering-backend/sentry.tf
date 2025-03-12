resource "sentry_project" "monoweb_kvittering_frontend" {
  organization = "dotkom"
  teams        = ["dotkom"]

  name = "Monoweb Kvittering Backend"
  slug = "monoweb-kvittering-backend"

  platform = "python-flask"
}
