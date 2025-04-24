module "gatus_evergreen_service" {
  source = "../../modules/evergreen-service"

  service_name = "monoweb-prd-gatus"

  acm_certificate_arns = [module.domain_certificate.certificate_arn]
  domain_names         = [local.domain_name]

  target_group_container_name = "monoweb-prd-gatus"
  target_group_container_port = 8080
  target_group_rule_priority  = 801

  task_count    = 1
  task_cpu      = 1024 / 8
  task_memory   = 1024 / 8
  task_role_arn = aws_iam_role.gatus.arn

  containers = [
    {
      container_name = "monoweb-prd-gatus"
      image          = data.aws_ecr_image.gatus.image_uri
      cpu            = 1024 / 8
      memory         = 1024 / 8
      essential      = true
      environment    = {}
      ports          = [{ container_port = 8080, protocol = "tcp" }]
    }
  ]
}
