resource "vault_mount" "mount_automate_v2" {
  path = "secret"
  type = "kv-v2"
}