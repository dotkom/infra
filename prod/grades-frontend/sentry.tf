resource "sentry_project" "grades_frontend" {
  organization = "dotkom"
  teams        = ["dotkom"]

  name = "Grades Frontend"
  slug = "grades-frontend"

  platform = "javascript-react"
}

resource "sentry_key" "grades_frontend" {
  organization = sentry_project.grades_frontend.organization
  project      = sentry_project.grades_frontend.slug

  name = "Production"
}
