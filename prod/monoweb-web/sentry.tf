resource "sentry_project" "monoweb_web" {
  organization = "dotkom"
  teams        = ["dotkom"]

  name = "Monoweb Web"
  slug = "monoweb-web"

  platform = "javascript-nextjs"
}

resource "sentry_key" "monoweb_web" {
  organization = sentry_project.monoweb_web.organization
  project      = sentry_project.monoweb_web.slug

  name = "Production"
}
