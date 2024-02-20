data "aws_route53_zone" "online" {
  name = "online.ntnu.no"
}

data "aws_subnet_ids" "subnets" {
  vpc_id = data.aws_vpc.default.id
}
data "aws_vpc" "default" {
  default = true
}
