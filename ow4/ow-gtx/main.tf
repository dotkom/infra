data "aws_route53_zone" "online" {
  name = "online.ntnu.no"
}

resource "aws_route53_record" "ow-gtx" {
  zone_id = data.aws_route53_zone.online.zone_id
  name    = "gtx.online.ntnu.no"
  type    = "CNAME"
  ttl     = "300"
  records = ["cname.vercel-dns.com"]
}