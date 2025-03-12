resource "sentry_project" "monoweb_rif" {
  organization = "dotkom"
  teams        = ["dotkom"]

  name = "Monoweb RIF"
  slug = "monoweb-rif"

  platform = "javascript-nextjs"
}
