resource "sentry_project" "monoweb_kvittering_frontend" {
  organization = "dotkom"
  teams        = ["dotkom"]

  name = "Monoweb Kvittering Frontend"
  slug = "monoweb-kvittering-frontend"

  platform = "javascript-react"
}
