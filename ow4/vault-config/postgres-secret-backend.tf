data "vault_generic_secret" "master_credentials" {
  path = "secret/rds-postgres"
}

resource "vault_mount" "postgres" {
  path = "postgres"
  type = "database"
}

resource "vault_database_secret_backend_connection" "postgres" {
  backend           = vault_mount.postgres.path
  name              = "postgres"
  verify_connection = true
  allowed_roles     = ["*"]
  postgresql {
    connection_url = "postgres://${data.vault_generic_secret.master_credentials.data["username"]}:${data.vault_generic_secret.master_credentials.data["password"]}@main-db.cxliesrki50e.eu-north-1.rds.amazonaws.com:5432/postgres"
  }
}