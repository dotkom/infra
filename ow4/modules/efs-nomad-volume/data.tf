data "nomad_plugin" "efs" {
  plugin_id        = "aws-efs"
  wait_for_healthy = true
}

data "aws_subnet_ids" "subnets" {
  vpc_id = data.aws_vpc.default.id
}
data "aws_vpc" "default" {
  default = true
}
