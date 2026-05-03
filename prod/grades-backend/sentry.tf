resource "sentry_project" "grades_backend" {
  organization = "dotkom"
  teams        = ["dotkom"]

  name = "Grades Backend"
  slug = "grades-backend"

  platform = "node"
}

resource "sentry_key" "grades_backend" {
  organization = sentry_project.grades_backend.organization
  project      = sentry_project.grades_backend.slug

  name = "Production"
}
