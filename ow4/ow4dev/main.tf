resource "aws_s3_bucket_versioning" "ow4" {
  bucket = aws_s3_bucket.ow4dev.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_acl" "ow4" {
  bucket = aws_s3_bucket.ow4dev.id
  acl    = "public-read"
}

resource "aws_s3_bucket_cors_configuration" "ow4" {
  bucket = aws_s3_bucket.ow4dev.id
  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket" "ow4dev" {
  bucket = "onlineweb4-dev"
}

resource "postgresql_database" "ow4dev" {
  name              = "ow4dev"
  allow_connections = true
  owner             = postgresql_role.ow4dev.name
}

resource "postgresql_role" "ow4dev" {
  name  = "ow4dev"
  login = false
}

resource "postgresql_grant" "ow4dev" {
  database    = postgresql_database.ow4dev.name
  role        = postgresql_role.ow4dev.name
  schema      = "public"
  object_type = "table"
  privileges = [
    "DELETE",
    "INSERT",
    "REFERENCES",
    "SELECT",
    "TRIGGER",
    "TRUNCATE",
    "UPDATE"
  ]
}

resource "vault_aws_auth_backend_role" "ow4dev" {
  backend                  = "aws"
  role                     = "ow4dev"
  auth_type                = "iam"
  bound_iam_principal_arns = ["arn:aws:iam:::role/onlineweb4-dev-ZappaLambdaExecutionRole"] //Zappa generates roles matching this
  token_policies           = [vault_policy.ow4dev.name]
  resolve_aws_unique_ids   = true
}

data "vault_policy_document" "ow4dev" {
  rule {
    path         = "secret/data/onlineweb4/dev/*"
    capabilities = ["read", "list"]
    description  = "Allow getting own secrets"
  }
  rule {
    path         = "postgres/creds/${vault_database_secret_backend_role.ow4dev.name}"
    capabilities = ["read"]
    description  = "Allow getting database credentials"
  }
}

resource "vault_database_secret_backend_role" "ow4dev" {
  backend = "postgres"
  name    = "ow4dev"
  db_name = "postgres"
  creation_statements = [
    "CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}' INHERIT",
    "GRANT ow4dev TO \"{{name}}\""
  ]
}

resource "vault_policy" "ow4dev" {
  name   = "ow4dev"
  policy = data.vault_policy_document.ow4dev.hcl
}

module "zappa_deploy_actions" {
  source = "../modules/zappa-deploy-actions"

  iam_user_name     = "ow4-deploy-dev"
  environment       = "Canary"
  deploy_bucket_arn = aws_s3_bucket.ow4dev.arn
  github_repository = "onlineweb4"
}
