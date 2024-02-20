resource "nomad_job" "loki" {
  jobspec = file("./files/loki.nomad")
}

resource "consul_config_entry" "intentions" {
  name = "loki"
  kind = "service-intentions"

  config_json = jsonencode({
    Sources = [
      {
        Action     = "allow"
        Name       = "grafana"
        Precedence = 9
        Type       = "consul"
      },
      {
        Action     = "allow"
        Name       = "loki-ingress"
        Precedence = 9
        Type       = "consul"
      }
    ]
  })
}

data "aws_iam_policy_document" "loki" {
  statement {
    actions = [
      "s3:ListBucket",
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject",
    ]
    effect    = "Allow"
    resources = [aws_s3_bucket.storage.arn, "${aws_s3_bucket.storage.arn}/*"]
  }
}

resource "vault_aws_secret_backend_role" "loki" {
  backend         = "aws"
  name            = "loki"
  credential_type = "iam_user"
  policy_document = data.aws_iam_policy_document.loki.json
}

resource "aws_s3_bucket" "storage" {
  bucket = "loki.dotkom"
  acl    = "private"
}

data "vault_policy_document" "loki" {
  rule {
    path         = "aws/creds/loki"
    capabilities = ["read"]
    description  = "Get aws creds"
  }

}

resource "vault_policy" "loki" {
  name   = "loki"
  policy = data.vault_policy_document.loki.hcl
}
