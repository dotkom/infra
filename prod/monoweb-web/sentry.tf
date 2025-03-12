resource "sentry_project" "monoweb_web" {
  organization = "dotkom"
  teams        = ["dotkom"]

  name = "Monoweb Web"
  slug = "monoweb-web"

  platform = "javascript-nextjs"
}
