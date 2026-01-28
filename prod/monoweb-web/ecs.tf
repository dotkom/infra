data "aws_vpc" "evergreen" {
  filter {
    name   = "tag:Name"
    values = ["evergreen-prod-vpc"]
  }
}

data "aws_subnets" "vpc_private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.evergreen.id]
  }
  filter {
    name   = "tag:Name"
    values = ["evergreen-prod-private-*"]
  }
}

data "aws_security_group" "evergreen_node" {
  name = "evergreen-prod-node"
}

module "web_evergreen_service" {
  source = "../../modules/evergreen-service"

  service_name = "monoweb-prd-web"

  acm_certificate_arns = [module.web_domain_certificate.certificate_arn]
  domain_names         = [local.web_domain_name]

  target_group_container_name = "monoweb-prd-web"
  target_group_container_port = 3000
  target_group_rule_priority  = 901

  task_count    = 1
  task_cpu      = 1024
  task_memory   = 1024 * 2
  task_role_arn = aws_iam_role.web.arn

  runtime_platform_architecture     = "ARM64"
  runtime_platform_operating_system = "LINUX"

  vpc_subnets        = data.aws_subnets.vpc_private.ids
  vpc_security_group = data.aws_security_group.evergreen_node.id

  containers = [
    {
      container_name = "monoweb-prd-web"
      image          = data.aws_ecr_image.web.image_uri
      cpu            = 1024
      memory         = 1024 * 2
      essential      = true
      environment    = data.doppler_secrets.monoweb_web.map
      ports          = [{ container_port = 3000, protocol = "tcp" }]
      healthcheck = {
        command = ["CMD-SHELL", "curl -f http://0.0.0.0:3000/health 2>/dev/null || exit 1"]
      }
    }
  ]
}
