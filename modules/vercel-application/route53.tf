resource "aws_route53_record" "domain" {
  name    = var.domain_name
  zone_id = var.zone_id
  type    = "CNAME"
  ttl     = "300"
  records = ["cname.vercel-dns.com"]
}

resource "aws_route53_record" "staging_domain" {
  count   = var.staging_domain_name != null ? 1 : 0
  name    = var.staging_domain_name
  zone_id = var.zone_id
  type    = "CNAME"
  ttl     = "300"
  records = ["cname.vercel-dns.com"]
}
