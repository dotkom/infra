resource "sentry_project" "monoweb_rif" {
  organization = "dotkom"
  teams        = ["dotkom"]

  name = "Monoweb RIF"
  slug = "monoweb-rif"

  platform = "javascript-nextjs"
}

resource "sentry_key" "monoweb_rif" {
  organization = sentry_project.monoweb_rif.organization
  project      = sentry_project.monoweb_rif.slug

  name = "Production"
}
