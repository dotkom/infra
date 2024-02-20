resource "consul_acl_policy" "anonymous" {
  name  = "anonymous"
  rules = <<-RULE
    node_prefix "" {
      policy = "write"
    }
    agent_prefix "" {
      policy = "write"
    }
    service_prefix "" {
      policy = "write"
    }
    query_prefix "" {
        policy = "read"
    }
  RULE
}



resource "consul_acl_token_policy_attachment" "anonymous" {
  token_id = "00000000-0000-0000-0000-000000000002" # Anonymous token
  policy   = consul_acl_policy.anonymous.name
}

resource "consul_acl_policy" "admin" {
  name  = "admin"
  rules = <<-RULE
    operator = "write"
    keyring = "write"
    acl = "write"
    node_prefix "" {
      policy = "write"
    }
    key_prefix "" {
      policy = "write"
    }
    node_key "" {
      policy = "write"
    }
    agent_prefix "" {
      policy = "write"
    }
    service_prefix "" {
      intentions = "write"
      policy = "write"
    }
    event_prefix "" {
        policy = "write"
    }
    query_prefix "" {
        policy = "write"
    }
    session_prefix "" {
        policy = "write"
    }
    RULE
}


resource "consul_acl_policy" "consul-server" {
  name  = "consul-server"
  rules = <<-RULE
    keyring = "write"

    agent_prefix "consul-server" {
        policy = "write"
    }

    node_prefix "consul-server" {
        policy = "write"
    }

    node_prefix "" {
        policy = "read"
    }

    agent_prefix "" {
        policy = "read"
    }

    service_prefix "" {
        policy = "read"
    }
    RULE
}


resource "consul_acl_policy" "vault-server" {
  name  = "vault-server"
  rules = <<-RULE
    agent_prefix "vault-server" {
        policy = "write"
    }

    node_prefix "vault-server" {
        policy = "write"
    }

    service "vault" {
      policy = "write"
    }

    node_prefix "" {
        policy = "read"
    }

    agent_prefix "" {
        policy = "read"
    }

    service_prefix "" {
        policy = "read"
    }
    RULE
}

resource "consul_acl_policy" "nomad-server" {
  name  = "nomad-server"
  rules = <<-RULE
    acl = "write"
    operator = "write"

    agent_prefix "nomad-server" {
        policy = "write"
    }
    node_prefix "nomad-server" {
        policy = "write"
    }
    service_prefix "" {
      policy = "write"
    }
    agent_prefix "" {
      policy = "read"
    }

    node_prefix "" {
      policy = "read"
    }
    query_prefix "" {
      policy = "read"
    }
    key_prefix "" {
      policy = "read"
    }
    RULE
}

resource "consul_acl_policy" "nomad-client" {
  name  = "nomad-client"
  rules = <<-RULE
    acl = "write"
    operator = "write"
    agent_prefix "nomad-client" {
        policy = "write"
    }

    node_prefix "nomad-client" {
        policy = "write"
    }

    service_prefix "" {
      policy = "write"
    }

    agent_prefix "" {
        policy = "read"
    }

    node_prefix "" {
      policy = "read"
    }

    query_prefix "" {
      policy = "read"
    }

    key_prefix "" {
      policy = "read"
    }
    RULE
}
