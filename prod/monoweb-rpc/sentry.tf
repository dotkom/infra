resource "sentry_project" "monoweb_rpc" {
  organization = "dotkom"
  teams        = ["dotkom"]

  name = "Monoweb RPC"
  slug = "monoweb-rpc"

  platform = "node"
}
