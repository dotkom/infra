resource "vercel_project" "owf" {
  name          = "onlineweb-frontend"
  team_id       = data.vercel_team.dotkom.id
  build_command = "yarn build"
  dev_command   = "yarn dev"
  framework     = "nextjs"
  git_repository {
    type = "github"
    repo = "dotkom/onlineweb-frontend"
  }
}

resource "consul_keys" "proxy" {
  key {
    path  = "traefik/http/routers/owf/rule"
    value = "Host(`online.ntnu.no`)"
  }
  key {
    path  = "traefik/http/routers/owf/service"
    value = "owf"
  }
  key {
    path  = "traefik/http/services/owf/loadbalancer/servers/0/url"
    value = "https://onlineweb-frontend.vercel.app"
  }
}

resource "aws_route53_record" "record" {
  zone_id = data.aws_route53_zone.online.zone_id
  name    = "online.ntnu.no"
  type    = "A"
  alias {
    name                   = "lb.online.ntnu.no"
    zone_id                = data.aws_route53_zone.online.zone_id
    evaluate_target_health = true
  }
}