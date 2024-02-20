resource "postgresql_database" "gradestats" {
  name              = "gradestats"
  allow_connections = true
}

resource "postgresql_role" "gradestats" {
  name     = "gradestats"
  login    = true
  password = data.vault_generic_secret.db_password.data["DATABASE_PASSWORD"]
}

data "vault_generic_secret" "db_password" {
  path = "secret/gradestats/postgres"
}

resource "postgresql_grant" "gradestats" {
  database    = postgresql_database.gradestats.name
  role        = postgresql_role.gradestats.name
  schema      = "public"
  object_type = "table"
  privileges  = ["ALL"]
}

