resource "sentry_project" "monoweb_admin" {
  organization = "dotkom"
  teams        = ["dotkom"]

  name = "Monoweb Admin"
  slug = "monoweb-admin"

  platform = "javascript-nextjs"
}

resource "sentry_key" "monoweb_admin" {
  organization = sentry_project.monoweb_admin.organization
  project      = sentry_project.monoweb_admin.slug

  name = "Production"
}

moved {
  from = sentry_project.monoweb_dashboard
  to   = sentry_project.monoweb_admin
}

moved {
  from = sentry_key.monoweb_dashboard
  to   = sentry_key.monoweb_admin
}
