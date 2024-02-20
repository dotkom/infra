resource "nomad_job" "prometheus" {
  jobspec = file("./files/prometheus.nomad")
}

data "vault_policy_document" "prometheus" {
  rule {
    path         = "sys/metrics"
    capabilities = ["read"]
    description  = "Monitor vault metrics"
  }
  rule {
    path         = "pki_int/issue/nomad-client"
    capabilities = ["update"]
    description  = "Issue Nomad client certificates"
  }
  rule {
    path         = "pki_int/issue/consul-client"
    capabilities = ["update"]
    description  = "Issue Consul client certificates"
  }
}
resource "vault_policy" "prometheus" {
  name   = "prometheus"
  policy = data.vault_policy_document.prometheus.hcl
}


resource "consul_config_entry" "intentions" {
  name = "prometheus"
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
        Name       = "traefik"
        Precedence = 9
        Type       = "consul"
      }
    ]
  })
}
resource "aws_route53_record" "prometheus" {
  zone_id = data.aws_route53_zone.online.zone_id
  name    = "prometheus.online.ntnu.no"
  type    = "CNAME"
  ttl     = "300"
  records = ["lb.online.ntnu.no"]
}

module "efs_nomad_volume" {
  source = "../modules/efs-nomad-volume"

  volume_id = "prometheus"
}