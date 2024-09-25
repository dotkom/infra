resource "aws_ecs_cluster" "evergreen" {
  name = "evergreen-prod-cluster"

  setting {
    // This is pretty pricey
    name  = "containerInsights"
    value = "disabled"
  }
}

resource "aws_ecs_capacity_provider" "ec2" {
  name = "evergreen-prod-ec2-nodes"

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.evergreen_node_scaling_group.arn
    managed_scaling {
      maximum_scaling_step_size = 1
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 80
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "evergreen" {
  cluster_name       = aws_ecs_cluster.evergreen.name
  capacity_providers = [aws_ecs_capacity_provider.ec2.name]

  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.ec2.name
    weight            = 100
    base              = 0
  }
}
