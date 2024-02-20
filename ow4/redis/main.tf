resource "nomad_job" "redis" {
  jobspec = file("./files/redis.nomad")
}

resource "random_password" "password" {
  length  = 64
  special = false
}

resource "consul_config_entry" "defaults" {
  kind = "service-defaults"
  name = "redis"

  config_json = jsonencode({
    Protocol : "tcp"
  })
}

resource "consul_config_entry" "intentions" {
  name = "redis"
  kind = "service-intentions"

  config_json = jsonencode({
    Sources = [
      {
        Action     = "allow"
        Name       = "onlineweb4"
        Precedence = 9
        Type       = "consul"
      },
      {
        Action     = "allow"
        Name       = "onlineweb4-celery"
        Precedence = 9
        Type       = "consul"
      }
    ]
  })
}

resource "vault_generic_secret" "password" {
  path = "secret/redis"

  data_json = jsonencode({
    password = random_password.password.result
  })
}

data "vault_policy_document" "redis" {
  rule {
    path         = "secret/data/redis"
    capabilities = ["read", "list"]
    description  = "Read own secrets"
  }
}

resource "vault_policy" "redis" {
  name   = "redis"
  policy = data.vault_policy_document.redis.hcl
}

resource "consul_config_entry" "service_intentions" {
  name = "redis"
  kind = "service-intentions"

  config_json = jsonencode({
    Sources = [
      {
        Action     = "allow"
        Name       = "onlineweb4"
        Precedence = 9
        Type       = "consul"
      },
      {
        Action     = "allow"
        Name       = "onlineweb4-celery"
        Precedence = 9
        Type       = "consul"
      }
    ]
  })
}