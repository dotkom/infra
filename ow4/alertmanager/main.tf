resource "nomad_job" "alertmanager" {
  jobspec = file("./files/alertmanager.nomad")
}

resource "consul_config_entry" "intentions" {
  name = "alertmanager"
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
        Name       = "loki"
        Precedence = 9
        Type       = "consul"
      },
      {
        Action     = "allow"
        Name       = "prometheus"
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

resource "aws_route53_record" "alertmanager" {
  zone_id = data.aws_route53_zone.online.zone_id
  name    = "alertmanager.online.ntnu.no"
  type    = "CNAME"
  ttl     = "300"
  records = ["lb.online.ntnu.no"]
}
