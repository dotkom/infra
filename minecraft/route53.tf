resource "aws_route53_record" "minecraft_server" {
  zone_id = data.aws_route53_zone.online.zone_id
  name    = "play.online.ntnu.no"
  type    = "A"
  ttl     = 300
  records = ["129.241.153.251"]
}
