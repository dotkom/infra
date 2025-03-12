resource "sentry_project" "monoweb_invoicification" {
  organization = "dotkom"
  teams        = ["dotkom"]

  name = "Monoweb Invocification"
  slug = "monoweb-invoicification"

  platform = "javascript-nextjs"
}
