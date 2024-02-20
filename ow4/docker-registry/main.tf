resource "nomad_job" "docker-registry" {
  jobspec = file("./files/docker-registry.nomad")
}

data "vault_policy_document" "docker-registry" {
  rule {
    path         = "aws/creds/docker-registry"
    capabilities = ["read"]
    description  = "Allow registry to get credentials for S3 writing"
  }
  rule {
    path         = "secret/data/docker-registry"
    capabilities = ["read"]
    description  = "Allow registry to read own secrets"
  }
}

resource "vault_policy" "docker-registry" {
  name   = "docker-registry"
  policy = data.vault_policy_document.docker-registry.hcl
}

resource "aws_route53_record" "docker-registry" {
  zone_id = data.aws_route53_zone.online.zone_id
  name    = "docker-registry.online.ntnu.no"
  type    = "CNAME"
  ttl     = "300"
  records = ["lb.online.ntnu.no"]
}

resource "random_password" "htpasswd" {
  length  = 32
  special = false
}

resource "random_password" "secret" {
  length  = 32
  special = false
}

resource "vault_generic_secret" "docker-registry" {
  path = "secret/docker-registry"
  data_json = jsonencode({
    username      = "dotokm"
    password      = random_password.htpasswd.result
    password_hash = bcrypt(random_password.htpasswd.result)
    secret        = random_password.secret.result
  })
}

resource "aws_s3_bucket" "storage" {
  bucket = "docker-registry.dotkom"
  acl    = "private"
}


data "aws_iam_policy_document" "docker-registry" {
  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation",
      "s3:ListBucketMultipartUploads"
    ]
    effect    = "Allow"
    resources = [aws_s3_bucket.storage.arn]
  }

  statement {
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject",
      "s3:ListMultipartUploadParts",
      "s3:AbortMultipartUpload",
    ]
    effect    = "Allow"
    resources = ["${aws_s3_bucket.storage.arn}/*"]
  }
}

resource "vault_aws_secret_backend_role" "docker-registry" {
  backend         = "aws"
  name            = "docker-registry"
  credential_type = "iam_user"
  policy_document = data.aws_iam_policy_document.docker-registry.json
}

resource "consul_config_entry" "intentions" {
  name = "docker-registry-ui"
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
