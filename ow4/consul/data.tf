data "aws_route53_zone" "online" {
  name = "online.ntnu.no"
}

data "aws_subnet" "selected" {
  id = "subnet-6eca3807"
}

data "aws_vpc" "selected" {
  id = data.aws_subnet.selected.vpc_id
}

data "aws_region" "current" {}

data "vault_generic_secret" "consul_server_token" {
  path = "secret/consul/acl/server"
}
