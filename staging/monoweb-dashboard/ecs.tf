module "dashboard_evergreen_service" {
  source = "../../modules/evergreen-service"

  service_name = "monoweb-staging-dashboard"

  acm_certificate_arns = [module.dashboard_domain_certificate.certificate_arn]
  domain_names         = [local.dashboard_domain_name]

  target_group_container_name = "monoweb-staging-dashboard"
  target_group_container_port = 3000
  target_group_rule_priority  = 1650

  task_count    = 1
  task_cpu      = 1024 / 8
  task_memory   = 1024 / 8
  task_role_arn = aws_iam_role.dashboard.arn

  containers = [
    {
      container_name = "monoweb-staging-dashboard"
      image          = data.aws_ecr_image.dashboard.image_uri
      cpu            = 1024 / 8
      memory         = 1024 / 8
      essential      = true
      environment    = data.doppler_secrets.monoweb_dashboard.map
      ports          = [{ container_port = 3000, protocol = "tcp" }]
      healthcheck = {
        command = ["CMD-SHELL", "curl -f http://0.0.0.0:3000/health 2>/dev/null || exit 1"]
      }
    }
  ]
}
