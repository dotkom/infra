data "aws_route53_zone" "online" {
  name = "online.ntnu.no"
}

data "nomad_plugin" "efs" {
  plugin_id        = "aws-efs"
  wait_for_healthy = true
}

data "aws_vpc" "default" {
  default = true
}
