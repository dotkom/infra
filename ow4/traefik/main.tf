resource "nomad_job" "traefik" {
  jobspec = file("./files/traefik.nomad")
}

resource "consul_keys" "config" {
  key {
    path  = "traefik/http/middlewares/default-basicauth/basicauth/usersfile"
    value = "/etc/traefik/.htpasswd"
  }
  key {
    path  = "traefik/http/middlewares/default-basicauth/basicauth/removeheader"
    value = "true"
  }
}

resource "consul_acl_policy" "traefik" {
  name  = "traefik"
  rules = <<-RULE
    key_prefix "traefik" {
      policy = "write"
    }

    service "traefik" {
      policy = "write"
    }

    agent_prefix "" {
      policy = "read"
    }

    node_prefix "" {
      policy = "read"
    }

    service_prefix "" {
      policy = "read"
    }
    RULE
}

resource "vault_consul_secret_backend_role" "traefik" {
  name     = "traefik"
  backend  = "consul"
  max_ttl  = 86400
  ttl      = 86400
  policies = ["traefik"]
}


data "vault_policy_document" "traefik" {
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
  rule {
    path         = "secret/data/traefik/*"
    capabilities = ["list", "read"]
    description  = "Read own secrets"
  }

  rule {
    path         = "secret/metadata/traefik/*"
    capabilities = ["list", "read"]
    description  = "Read own secrets"
  }

  rule {
    path         = "consul/creds/traefik"
    capabilities = ["read"]
    description  = "Issue Consul ACL token"
  }
}
resource "vault_policy" "traefik" {
  name   = "traefik"
  policy = data.vault_policy_document.traefik.hcl
}

resource "aws_route53_record" "traefik" {
  zone_id = data.aws_route53_zone.online.zone_id
  name    = "traefik.online.ntnu.no"
  type    = "CNAME"
  ttl     = "300"
  records = ["lb.online.ntnu.no"]
}