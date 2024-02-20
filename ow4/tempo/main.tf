resource "nomad_job" "tempo" {
  jobspec = file("./files/tempo.nomad")
}

resource "consul_config_entry" "intentions" {
  name = "tempo"
  kind = "service-intentions"

  config_json = jsonencode({
    Sources = [
      {
        Action     = "allow"
        Name       = "grafana"
        Precedence = 9
        Type       = "consul"
      }
    ]
  })
}

resource "consul_config_entry" "jaeger-collector-grpc-intentions" {
  name = "tempo-jaeger-collector-grpc"
  kind = "service-intentions"

  config_json = jsonencode({
    Sources = [
      {
        Action     = "allow"
        Name       = "jaeger-agent"
        Precedence = 9
        Type       = "consul"
      }
    ]
  })
}

resource "consul_config_entry" "jaeger-collector-grpc-defaults" {
  name = "tempo-jaeger-collector-grpc"
  kind = "service-defaults"

  config_json = jsonencode({
    Protocol : "grpc"
  })
}
data "aws_iam_policy_document" "tempo" {
  statement {
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:DeleteObject",
      "s3:GetObjectTagging",
      "s3:PutObjectTagging"
    ]
    effect    = "Allow"
    resources = [aws_s3_bucket.storage.arn, "${aws_s3_bucket.storage.arn}/*"]
  }
}

resource "vault_aws_secret_backend_role" "tempo" {
  backend         = "aws"
  name            = "tempo"
  credential_type = "iam_user"
  policy_document = data.aws_iam_policy_document.tempo.json
}

resource "aws_s3_bucket" "storage" {
  bucket = "tempo.dotkom"
  acl    = "private"
}

data "vault_policy_document" "tempo" {
  rule {
    path         = "aws/creds/tempo"
    capabilities = ["read"]
    description  = "Get aws creds"
  }
}

resource "vault_policy" "tempo" {
  name   = "tempo"
  policy = data.vault_policy_document.tempo.hcl
}

