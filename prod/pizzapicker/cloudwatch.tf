resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/pizza-picker-prod"
  retention_in_days = 14
}
