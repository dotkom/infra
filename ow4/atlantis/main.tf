resource "nomad_job" "atlantis" {
  jobspec = file("./files/atlantis.nomad")
}

data "aws_iam_policy_document" "atlantis" {
  statement {
    actions = [
      "ec2:*",
      "s3:*",
      "rds:*",
      "iam:*",
      "route53:*",
      "dynamodb:*",
      "acm:*",
      "elasticloadbalancing:*",
      "autoscaling:*",
      "elasticfilesystem:*",
    "kms:*"]
    effect    = "Allow"
    resources = ["*"]
  }
}

resource "vault_aws_secret_backend_role" "atlantis" {
  backend         = "aws"
  name            = "atlantis"
  credential_type = "iam_user"
  policy_document = data.aws_iam_policy_document.atlantis.json
}

data "vault_policy_document" "atlantis" {
  rule {
    path         = "*"
    capabilities = ["create", "read", "list", "update", "update", "delete", "sudo"]
    description  = "Allow everything :("
  }

}

resource "vault_policy" "atlantis" {
  name   = "atlantis"
  policy = data.vault_policy_document.atlantis.hcl
}

resource "aws_route53_record" "atlantis" {
  zone_id = data.aws_route53_zone.online.zone_id
  name    = "atlantis.online.ntnu.no"
  type    = "CNAME"
  ttl     = "300"
  records = ["lb.online.ntnu.no"]
}

resource "vault_consul_secret_backend_role" "atlantis" {
  name     = "atlantis"
  backend  = "consul"
  max_ttl  = 2592000
  ttl      = 86400
  policies = ["admin"]
}


resource "postgresql_role" "atlantis" {
  name            = "atlantis"
  login           = true
  create_database = true
  create_role     = true
}

resource "vault_database_secret_backend_static_role" "static_role" {
  backend             = "postgres"
  name                = "atlantis"
  db_name             = "postgres"
  username            = "atlantis"
  rotation_period     = "86400"
  rotation_statements = ["ALTER USER \"{{name}}\" WITH PASSWORD '{{password}}';"]
}

resource "consul_config_entry" "intentions" {
  name = "atlantis"
  kind = "service-intentions"

  config_json = jsonencode({
    Sources = [
      {
        Action     = "allow"
        Name       = "traefik"
        Precedence = 9
        Type       = "consul"
      }
    ]
  })
}

module "efs_nomad_volume" {
  source = "../modules/efs-nomad-volume"

  volume_id = "atlantis"
}