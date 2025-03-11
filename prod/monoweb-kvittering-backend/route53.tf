locals {
  domain_name = "api.kvittering.online.ntnu.no"
}

data "aws_route53_zone" "online_ntnu_no" {
  name = "online.ntnu.no"
}

data "aws_lb" "evergreen_gateway" {
  name = "evergreen-prod-gateway"
}

resource "aws_route53_record" "kvittering_alb" {
  name    = local.domain_name
  type    = "A"
  zone_id = data.aws_route53_zone.online_ntnu_no.zone_id

  alias {
    name                   = data.aws_lb.evergreen_gateway.dns_name
    zone_id                = data.aws_lb.evergreen_gateway.zone_id
    evaluate_target_health = false
  }
}

# Switch to this for routing traffic to old kvittering website
# Uncomment this and comment out the above record to switch to Vercel
# resource "aws_route53_record" "kvittering_vercel" {
#   name    = "kvittering.online.ntnu.no"
#   type    = "CNAME"
#   zone_id = data.aws_route53_zone.online_ntnu_no.zone_id
#   ttl     = 300
#   records = ["cname.vercel-dns.com."]
# }
