resource "sentry_project" "monoweb_dashboard" {
  organization = "dotkom"
  teams        = ["dotkom"]

  name = "Monoweb Dashboard"
  slug = "monoweb-dashboard"

  platform = "javascript-nextjs"
}
