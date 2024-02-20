data "aws_route53_zone" "online" {
  name = "online.ntnu.no"
}

data "vercel_team" "dotkom" {
  slug = "dotkom"
}