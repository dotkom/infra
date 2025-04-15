data "sentry_project" "monoweb_rpc" {
  organization = "dotkom"
  slug         = "monoweb-rpc"
}

resource "sentry_key" "monoweb_rpc" {
  organization = data.sentry_project.monoweb_rpc.organization
  project      = data.sentry_project.monoweb_rpc.slug

  name = "Staging"
}