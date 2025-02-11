data "aws_route53_zone" "online_ntnu_no" {
  name = "online.ntnu.no"
}

data "aws_lb" "evergreen_gateway" {
  name = "evergreen-prod-gateway"
}
