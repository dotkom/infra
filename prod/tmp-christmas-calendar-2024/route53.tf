data "aws_route53_zone" "online_ntnu_no" {
  name = "online.ntnu.no"
}

resource "aws_route53_record" "domain_record" {
  name    = "jul.online.ntnu.no"
  zone_id = data.aws_route53_zone.online_ntnu_no.zone_id
  type    = "CNAME"
  ttl     = "300"
  records = ["cname.vercel-dns.com"]
}

resource "aws_route53_record" "vercel_verification" {
  name    = "_vercel"
  zone_id = data.aws_route53_zone.online_ntnu_no.zone_id
  type    = "TXT"
  ttl     = "300"
  records = ["vc-domain-verify=jul.online.ntnu.no,64c883239edfaebaebc8"]
}