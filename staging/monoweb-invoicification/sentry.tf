data "sentry_project" "monoweb_invoicification" {
  organization = "dotkom"
  slug         = "monoweb-invoicification"
}

resource "sentry_key" "monoweb_invoicification" {
  organization = data.sentry_project.monoweb_invoicification.organization
  project      = data.sentry_project.monoweb_invoicification.slug

  name = "Staging"
}
