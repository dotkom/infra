resource "vault_policy" "admin" {
  name = "admin"

  policy = <<EOT
  path "*" {
    capabilities = ["create", "read", "update", "delete", "list", "sudo"]
  }
EOT
}

resource "vault_policy" "dotkom" {
  name = "dotkom"

  policy = <<EOT
  path "*" {
    capabilities = ["list"]
  }

  path "secret/*" {
    capabilities = ["create", "read", "update", "delete", "list", "sudo"]
  }
  path "ssh-client-signer/*" {
    capabilities = ["create", "read", "update", "delete", "list", "sudo"]
  }
EOT
}

resource "vault_policy" "vm" {
  name = "vm"

  policy = <<EOT
    path "ssh-host-signer/sign/default" {
      capabilities = ["create", "read", "update"]
    }
    path "ssh-client-signer/config/ca" {
      capabilities = ["read"]
    }
  EOT
}

resource "vault_policy" "consul_client" {
  name = "consul-client"

  policy = <<EOT
    path "secret/data/consul/*" {
      capabilities = ["read", "list"]
    }
    path "pki_int/issue/consul-client" {
      capabilities = ["update"]
    }
    path "consul/creds/consul-client" {
      capabilities = ["read"]
    }
  EOT
}

resource "vault_policy" "consul_server" {
  name = "consul-server"

  policy = <<EOT
    path "pki_int/issue/consul-server" {
      capabilities = ["update"]
    }
    path "consul/creds/consul-server" {
      capabilities = ["read"]
    }
    path "secret/data/traefik/basicauth" {
      capabilities = ["read"]
    }
  EOT
}

resource "vault_policy" "vault_server" {
  name = "vault-server"

  policy = <<EOT
    path "consul/creds/vault-server" {
      capabilities = ["read"]
    }
  EOT
}

resource "vault_policy" "nomad_client" {
  name = "nomad-client"

  policy = <<EOT
    path "secret/data/nomad/*" {
      capabilities = ["read", "list"]
    }
    path "pki_int/issue/nomad-client" {
      capabilities = ["update"]
    }
    path "consul/creds/nomad-client" {
      capabilities = ["read"]
    }
  EOT
}

resource "vault_policy" "nomad_server" {
  name = "nomad-server"

  policy = <<EOT
    path "pki_int/issue/nomad-server" {
      capabilities = ["update"]
    }

    path "auth/token/create" {
      capabilities = ["create", "update", "sudo"]
      allowed_parameters = {
        policy = ["nomad-server"]
        orphan = []
        period = []
      }
    }

    path "auth/token/create/nomad-cluster" {
      capabilities = ["create", "update"]
    }

    path "auth/token/roles/nomad-cluster" {
      capabilities = ["read"]
    }

    path "auth/token/lookup-self" {
      capabilities = ["read"]
    }

    path "auth/token/lookup" {
      capabilities = ["update"]
    }

    path "auth/token/revoke-accessor" {
      capabilities = ["update"]
    }

    path "sys/capabilities-self" {
      capabilities = ["update"]
    }

    path "auth/token/renew-self" {
      capabilities = ["update"]
    }
    path "consul/creds/nomad-server" {
      capabilities = ["read"]
    }
  EOT
}
