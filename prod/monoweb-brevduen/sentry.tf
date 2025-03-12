resource "sentry_project" "monoweb_brevduen" {
  organization = "dotkom"
  teams        = ["dotkom"]

  name = "Monoweb Brevduen"
  slug = "monoweb-brevduen"

  platform = "node-awslambda"
}
