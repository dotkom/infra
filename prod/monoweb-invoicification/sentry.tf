resource "sentry_project" "monoweb_invoicification" {
  organization = "dotkom"
  teams        = ["dotkom"]

  name = "Monoweb Invocification"
  slug = "monoweb-invoicification"

  platform = "javascript-nextjs"
}

resource "sentry_key" "monoweb_invoicification" {
  organization = sentry_project.monoweb_invoicification.organization
  project      = sentry_project.monoweb_invoicification.slug

  name = "Production"
}
