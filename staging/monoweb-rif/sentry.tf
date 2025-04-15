data "sentry_project" "monoweb_rif" {
  organization = "dotkom"
  slug         = "monoweb-rif"
}

resource "sentry_key" "monoweb_rif" {
  organization = data.sentry_project.monoweb_rif.organization
  project      = data.sentry_project.monoweb_rif.slug

  name = "Staging"
}