resource "aws_route53_record" "minecraft_server" {
  zone_id = data.aws_route53_zone.online.zone_id
  name    = "play.online.ntnu.no"
  type    = "A"
  ttl     = 300
  records = ["10.212.26.1"]
}