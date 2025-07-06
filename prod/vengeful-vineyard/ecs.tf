module "server_evergreen_service" {
  source = "../../modules/evergreen-service"

  service_name = "vengeful-vineyard-prod-server"

  acm_certificate_arns = [module.server_certificate.certificate_arn]
  domain_names         = [local.vengeful_server_domain_name]

  target_group_container_name = "vengeful-vineyard-prod-server"
  target_group_container_port = 8000
  target_group_rule_priority  = 1400

  task_count    = 1
  task_cpu      = 1024 / 4
  task_memory   = 1024 / 2
  task_role_arn = aws_iam_role.server.arn

  runtime_platform_architecture = "X86_64"
  runtime_platform_operating_system = "LINUX"

  containers = [
    {
      container_name = "vengeful-vineyard-prod-server"
      image          = data.aws_ecr_image.server.image_uri
      cpu            = 1024 / 4
      memory         = 1024 / 2
      essential      = true
      environment    = data.doppler_secrets.vengeful.map
      ports          = [{ container_port = 8000, protocol = "tcp" }]
      healthcheck = {
        command = ["CMD-SHELL", "curl -f http://0.0.0.0:8000/health 2>/dev/null || exit 1"]
      }
    }
  ]
}
