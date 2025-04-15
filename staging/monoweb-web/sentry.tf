data "sentry_project" "monoweb_web" {
  organization = "dotkom"
  slug         = "monoweb-web"
}

resource "sentry_key" "monoweb_web" {
  organization = data.sentry_project.monoweb_web.organization
  project      = data.sentry_project.monoweb_web.slug

  name = "Staging"
}
