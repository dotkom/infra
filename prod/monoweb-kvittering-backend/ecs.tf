module "evergreen_service" {
  source = "../../modules/evergreen-service"

  service_name = "monoweb-prod-${local.project_name}"

  acm_certificate_arns = [module.domain_certificate.certificate_arn]
  domain_names         = [local.domain_name]

  target_group_container_name = "monoweb-prod-${local.project_name}"
  target_group_container_port = 5000
  target_group_rule_priority  = 1800

  task_count    = 1
  task_cpu      = 1024 / 4
  task_memory   = 1024 / 4
  task_role_arn = aws_iam_role.task_role.arn

  containers = [
    {
      container_name = "monoweb-prod-${local.project_name}"
      image          = data.aws_ecr_image.this.image_uri
      cpu            = 1024 / 4
      memory         = 1024 / 4
      essential      = true
      environment = {
        RECIPIENT_EMAIL     = "kvittering@online.ntnu.no"
        CC_RECIPIENT_EMAILS = "online-linjeforeningen-for-informatikk1@bilag.fiken.no"
        SENDER_EMAIL        = "kvitteringsbot@online.ntnu.no"
        STORAGE_BUCKET      = "kvittering-archive.online.ntnu.no"
        EMAIL_ENABLED       = "true",
      }
      ports = [{ container_port = 5000, protocol = "tcp" }]
      healthcheck = {
        command = ["CMD-SHELL", "curl -f http://0.0.0.0:5000/health 2>/dev/null || exit 1"]
      }
    }
  ]
}
