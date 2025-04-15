data "sentry_project" "monoweb_brevduen" {
  organization = "dotkom"
  slug         = "monoweb-brevduen"
}

resource "sentry_key" "monoweb_brevduen" {
  organization = data.sentry_project.monoweb_brevduen.organization
  project      = data.sentry_project.monoweb_brevduen.slug

  name = "Staging"
}
