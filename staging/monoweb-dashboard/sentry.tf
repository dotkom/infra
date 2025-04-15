data "sentry_project" "monoweb_dashboard" {
  organization = "dotkom"
  slug         = "monoweb-dashboard"
}

resource "sentry_key" "monoweb_dashboard" {
  organization = data.sentry_project.monoweb_dashboard.organization
  project      = data.sentry_project.monoweb_dashboard.slug

  name = "Staging"
}