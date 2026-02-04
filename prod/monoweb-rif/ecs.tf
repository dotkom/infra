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

module "rif_evergreen_service" {
  source = "../../modules/evergreen-service"

  service_name = "monoweb-prd-rif"

  acm_certificate_arns = [module.rif_certificate.certificate_arn]
  domain_names         = [local.rif_domain_name]

  target_group_container_name = "monoweb-prd-rif"
  target_group_container_port = 3000
  target_group_rule_priority  = 1100

  task_count    = 1
  task_cpu      = 1024 / 4
  task_memory   = 1024 / 2
  task_role_arn = aws_iam_role.ecs_task.arn

  runtime_platform_architecture     = "ARM64"
  runtime_platform_operating_system = "LINUX"

  vpc_subnets        = data.aws_subnets.vpc_private.ids
  vpc_security_group = data.aws_security_group.evergreen_node.id

  containers = [
    {
      container_name = "monoweb-prd-rif"
      image          = data.aws_ecr_image.rif.image_uri
      cpu            = 1024 / 4
      memory         = 1024 / 2
      essential      = true
      environment    = data.doppler_secrets.rif.map
      ports          = [{ container_port = 3000, protocol = "tcp" }]
      healthcheck = {
        enabled = true
        command = ["CMD-SHELL", "curl -f http://0.0.0.0:3000/health 2>/dev/null || exit 1"]
      }
    }
  ]
}
