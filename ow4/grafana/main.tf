resource "nomad_job" "grafana" {
  jobspec = file("./files/grafana.nomad")
}

resource "aws_route53_record" "grafana" {
  zone_id = data.aws_route53_zone.online.zone_id
  name    = "grafana.online.ntnu.no"
  type    = "CNAME"
  ttl     = "300"
  records = ["lb.online.ntnu.no"]
}

resource "vault_aws_secret_backend_role" "grafana" {
  backend         = "aws"
  name            = "grafana"
  credential_type = "iam_user"
  policy_document = data.aws_iam_policy_document.grafana.json
}

data "vault_policy_document" "grafana" {
  rule {
    path         = "/aws/creds/grafana"
    capabilities = ["read"]
  }

  rule {
    path         = "postgres/static-creds/${vault_database_secret_backend_static_role.grafana.name}"
    capabilities = ["read"]
    description  = "Allow app to generate dynamic DB credentials"
  }
}

resource "vault_policy" "grafana" {
  name   = "grafana"
  policy = data.vault_policy_document.grafana.hcl
}

data "aws_iam_policy_document" "grafana" {

  statement {
    sid = "AllowReadingMetricsFromCloudWatch"
    actions = [
      "cloudwatch:DescribeAlarmsForMetric",
      "cloudwatch:DescribeAlarmHistory",
      "cloudwatch:DescribeAlarms",
      "cloudwatch:ListMetrics",
      "cloudwatch:GetMetricStatistics",
      "cloudwatch:GetMetricData"
    ]
    resources = ["*"]
  }
  statement {
    sid = "AllowReadingLogsFromCloudWatch"
    actions = [
      "logs:DescribeLogGroups",
      "logs:GetLogGroupFields",
      "logs:StartQuery",
      "logs:StopQuery",
      "logs:GetQueryResults",
      "logs:GetLogEvents"
    ]
    resources = ["*"]
  }
  statement {
    sid       = "AllowReadingTagsInstancesRegionsFromEC2"
    actions   = ["ec2:DescribeTags", "ec2:DescribeInstances", "ec2:DescribeRegions"]
    resources = ["*"]
  }
  statement {
    sid       = "AllowReadingResourcesForTags"
    actions   = ["tag:GetResources"]
    resources = ["*"]
  }
}

resource "consul_config_entry" "intentions" {
  name = "grafana"
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

resource "postgresql_database" "grafana" {
  name              = "grafana"
  owner             = "grafana"
  allow_connections = true
  depends_on = [
    postgresql_role.grafana
  ]
}

resource "postgresql_role" "grafana" {
  name  = "grafana"
  login = true
}

resource "postgresql_grant" "grafana" {
  database    = postgresql_database.grafana.name
  role        = postgresql_role.grafana.name
  schema      = "public"
  object_type = "table"
  privileges  = ["ALL"]
}

resource "vault_database_secret_backend_static_role" "grafana" {
  backend             = "postgres"
  name                = postgresql_role.grafana.name
  db_name             = "postgres"
  username            = postgresql_role.grafana.name
  rotation_period     = "86400"
  rotation_statements = ["ALTER USER \"{{name}}\" WITH PASSWORD '{{password}}';"]
}