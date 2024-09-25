resource "aws_cloudwatch_log_group" "rif" {
  name = "/ecs/monoweb/prod/rif"

  retention_in_days = 30
}
