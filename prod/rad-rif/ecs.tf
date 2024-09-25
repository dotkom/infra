module "rif_evergreen_service" {
  source = "../../modules/evergreen-service"

  service_name = "monoweb-prod-rif"

  acm_certificate_arns = [module.rif_certificate.certificate_arn]
  domain_names         = [local.rif_domain_name]

  target_group_container_name = "monoweb-prod-rif"
  target_group_container_port = 3000
  target_group_rule_priority  = 1100

  task_count    = 1
  task_cpu      = 256
  task_memory   = 256
  task_role_arn = aws_iam_role.ecs_task.arn

  containers = [
    {
      container_name = "monoweb-prod-rif"
      image          = data.aws_ecr_image.rif.image_uri
      cpu            = 256
      memory         = 256
      essential      = true
      environment    = data.doppler_secrets.rif.map
      ports          = [{ container_port = 3000, protocol = "tcp" }]
      healthcheck = {
        enabled = true
        command = ["CMD-SHELL", "curl -f http://0.0.0.0:3000 || exit 1"]
      }
    }
  ]
}
