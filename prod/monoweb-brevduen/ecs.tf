module "brevduen_evergreen_service" {
  source = "../../modules/evergreen-service"

  service_name = "monoweb-prod-brevduen"

  acm_certificate_arns = [module.brevduen_domain_certificate.certificate_arn]
  domain_names         = [local.brevduen_domain_name]

  target_group_container_name = "monoweb-prod-brevduen"
  target_group_container_port = 4433
  target_group_rule_priority  = 1900

  task_count    = 1
  task_cpu      = 1024 / 8
  task_memory   = 1024 / 8
  task_role_arn = aws_iam_role.brevduen.arn

  containers = [
    {
      container_name = "monoweb-prod-brevduen"
      image          = data.aws_ecr_image.brevduen.image_uri
      cpu            = 1024 / 8
      memory         = 1024 / 8
      essential      = true
      environment    = data.doppler_secrets.monoweb_brevduen.map
      ports          = [{ container_port = 4433, protocol = "tcp" }]
      healthcheck = {
        command = ["CMD-SHELL", "curl -f http://0.0.0.0:4433/health 2>/dev/null || exit 1"]
      }
    }
  ]
}
