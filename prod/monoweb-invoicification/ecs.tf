module "invoicification_evergreen_service" {
  source = "../../modules/evergreen-service"

  service_name = "monoweb-prd-invoicification"

  acm_certificate_arns = [module.invoicification_certificate.certificate_arn]
  domain_names         = [local.invoicification_domain_name]

  target_group_container_name = "monoweb-prd-invoicification"
  target_group_container_port = 3000
  target_group_rule_priority  = 1500

  task_count    = 1
  task_cpu      = 1024 / 8
  task_memory   = 1024 / 8
  task_role_arn = aws_iam_role.invoicification.arn

  runtime_platform_architecture     = "ARM64"
  runtime_platform_operating_system = "LINUX"

  containers = [
    {
      container_name = "monoweb-prd-invoicification"
      image          = data.aws_ecr_image.invoicification.image_uri
      cpu            = 1024 / 8
      memory         = 1024 / 8
      essential      = true
      environment    = data.doppler_secrets.invoicification.map
      ports          = [{ container_port = 3000, protocol = "tcp" }]
      healthcheck = {
        enabled = true
        command = ["CMD-SHELL", "curl -f http://0.0.0.0:3000/health 2>/dev/null || exit 1"]
      }
    }
  ]
}
