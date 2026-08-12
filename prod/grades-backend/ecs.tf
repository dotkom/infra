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

module "backend_evergreen_service" {
  source = "../../modules/evergreen-service"

  service_name = "grades-prd-backend"

  acm_certificate_arns = [module.backend_domain_certificate.certificate_arn]
  domain_names         = [local.backend_domain_name]

  target_group_container_name = "grades-prd-backend"
  target_group_container_port = 5555
  target_group_rule_priority  = 1100

  task_count    = 1
  task_cpu      = 1024 / 4
  task_memory   = 1024 / 2
  task_role_arn = aws_iam_role.backend.arn

  runtime_platform_architecture     = "ARM64"
  runtime_platform_operating_system = "LINUX"

  vpc_subnets        = data.aws_subnets.vpc_private.ids
  vpc_security_group = data.aws_security_group.evergreen_node.id

  containers = [
    {
      container_name = "grades-prd-backend"
      image          = data.aws_ecr_image.backend.image_uri
      cpu            = 1024 / 4
      memory         = 1024 / 2
      essential      = true
      environment    = data.doppler_secrets.grades_backend.map
      ports          = [{ container_port = 5555, protocol = "tcp" }]
      healthcheck = {
        command = ["CMD-SHELL", "curl -f http://0.0.0.0:5555/health 2>/dev/null || exit 1"]
      }
    }
  ]
}
