resource "postgresql_database" "onlineweb4" {
  name              = "onlineweb4"
  allow_connections = true
  owner             = postgresql_role.onlineweb4.name
}

resource "postgresql_role" "onlineweb4" {
  name  = "onlineweb4"
  login = false
}

resource "postgresql_grant" "onlineweb4" {
  database    = postgresql_database.onlineweb4.name
  role        = postgresql_role.onlineweb4.name
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

resource "aws_s3_bucket_versioning" "ow4" {
  bucket = aws_s3_bucket.ow4.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_acl" "ow4" {
  bucket = aws_s3_bucket.ow4.id
  acl    = "public-read"
}

resource "aws_s3_bucket_cors_configuration" "ow4" {
  bucket = aws_s3_bucket.ow4.id
  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket" "ow4" {
  bucket = "onlineweb4-prod"
}

resource "vault_aws_auth_backend_role" "ow4" {
  backend                  = "aws"
  role                     = "ow4"
  auth_type                = "iam"
  bound_iam_principal_arns = ["arn:aws:iam:::role/onlineweb4-prod-ZappaLambdaExecutionRole"] //Zappa generates roles matching this
  token_policies           = [vault_policy.ow4.name]
  resolve_aws_unique_ids   = true
}

data "vault_policy_document" "ow4" {
  rule {
    path         = "secret/data/onlineweb4/*"
    capabilities = ["read", "list"]
    description  = "Allow getting own secrets"
  }
  rule {
    path         = "postgres/creds/${vault_database_secret_backend_role.ow4.name}"
    capabilities = ["read"]
    description  = "Allow getting database credentials"
  }
}

resource "vault_database_secret_backend_role" "ow4" {
  backend = "postgres"
  name    = "ow4"
  db_name = "postgres"
  creation_statements = [
    "CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}' INHERIT",
    "GRANT onlineweb4 TO \"{{name}}\""
  ]
}

resource "vault_policy" "ow4" {
  name   = "ow4"
  policy = data.vault_policy_document.ow4.hcl
}

module "zappa_deploy_actions" {
  source = "../modules/zappa-deploy-actions"

  iam_user_name     = "ow4-deploy-prod"
  environment       = "Production"
  deploy_bucket_arn = aws_s3_bucket.ow4.arn
  github_repository = "onlineweb4"
}
