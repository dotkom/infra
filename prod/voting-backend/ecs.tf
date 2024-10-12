module "voting_evergreen_service" {
  source = "../../modules/evergreen-service"

  service_name = "voting-prod-server"

  acm_certificate_arns = [module.voting_domain_certificate.certificate_arn]
  domain_names         = [local.voting_domain_name]

  target_group_container_name = "voting-prod-server"
  target_group_container_port = 4000
  target_group_rule_priority  = 1700

  task_count    = 1
  task_cpu      = 1024 / 8
  task_memory   = 1024 / 8
  task_role_arn = aws_iam_role.voting.arn

  containers = [
    {
      container_name = "voting-prod-server"
      image          = data.aws_ecr_image.voting.image_uri
      cpu            = 1024 / 8
      memory         = 1024 / 8
      essential      = true
      environment    = data.doppler_secrets.voting_backend.map
      ports          = [{ container_port = 4000, protocol = "tcp" }]
      healthcheck = {
        command = ["CMD-SHELL", "curl -f http://0.0.0.0:4000/health 2>/dev/null || exit 1"]
      }
    }
  ]
}
