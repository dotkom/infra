resource "vault_aws_auth_backend_role" "defualt" {
  backend                = vault_auth_backend.aws.path
  role                   = "default"
  auth_type              = "iam"
  bound_account_ids      = ["891459268445"]
  inferred_entity_type   = "ec2_instance"
  inferred_aws_region    = "eu-north-1"
  token_period           = 86400
  token_policies         = [vault_policy.vm.name]
  token_explicit_max_ttl = 0
}

resource "vault_aws_auth_backend_role" "consul-server" {
  backend                = vault_auth_backend.aws.path
  role                   = "consul-server"
  auth_type              = "iam"
  bound_account_ids      = ["891459268445"]
  inferred_entity_type   = "ec2_instance"
  inferred_aws_region    = "eu-north-1"
  token_period           = 86400
  token_policies         = [vault_policy.vm.name, vault_policy.consul_client.name, vault_policy.consul_server.name]
  token_explicit_max_ttl = 0
}

resource "vault_aws_auth_backend_role" "vault-server" {
  backend                = vault_auth_backend.aws.path
  role                   = "vault-server"
  auth_type              = "iam"
  bound_account_ids      = ["891459268445"]
  inferred_entity_type   = "ec2_instance"
  inferred_aws_region    = "eu-north-1"
  token_period           = 86400
  token_policies         = [vault_policy.vm.name, vault_policy.consul_client.name, vault_policy.vault_server.name]
  token_explicit_max_ttl = 0
}

resource "vault_aws_auth_backend_role" "nomad_server" {
  backend              = vault_auth_backend.aws.path
  role                 = "nomad-server"
  auth_type            = "iam"
  bound_account_ids    = ["891459268445"]
  inferred_entity_type = "ec2_instance"
  inferred_aws_region  = "eu-north-1"
  token_period         = 86400
  token_policies = [
    "default",
    vault_policy.vm.name,
    vault_policy.consul_client.name,
    vault_policy.nomad_client.name,
    vault_policy.nomad_server.name
  ]
  token_explicit_max_ttl = 0
}

resource "vault_aws_auth_backend_role" "nomad_client" {
  backend              = vault_auth_backend.aws.path
  role                 = "nomad-client"
  auth_type            = "iam"
  bound_account_ids    = ["891459268445"]
  inferred_entity_type = "ec2_instance"
  inferred_aws_region  = "eu-north-1"
  token_period         = 86400
  token_policies = [
    vault_policy.vm.name,
    vault_policy.consul_client.name,
    vault_policy.nomad_client.name,
  ]
  token_explicit_max_ttl = 0
}
