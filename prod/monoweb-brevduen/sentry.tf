resource "sentry_project" "monoweb_brevduen" {
  organization = "dotkom"
  teams        = ["dotkom"]

  name = "Monoweb Brevduen"
  slug = "monoweb-brevduen"

  platform = "node"
}

resource "sentry_key" "monoweb_brevduen" {
  organization = sentry_project.monoweb_brevduen.organization
  project      = sentry_project.monoweb_brevduen.slug

  name = "Production"
}
