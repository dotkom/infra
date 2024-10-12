resource "aws_ecs_task_definition" "rif" {
  family = var.service_name

  requires_compatibilities = ["EC2"]
  network_mode             = "bridge"
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  execution_role_arn       = data.aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([
    for container in var.containers : {
      name      = container.container_name
      image     = container.image
      cpu       = container.cpu
      memory    = container.memory
      essential = container.essential
      environment = [
        for key, value in container.environment : {
          name  = key
          value = value
        }
      ]
      portMappings = [
        for port in container.ports : {
          containerPort = port.container_port
          protocol      = port.protocol
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.this.name
          awslogs-region        = "eu-north-1"
          awslogs-stream-prefix = "ecs/evergreen/${var.service_name}"
        }
      }
      healthCheck = {
        command = container.healthcheck.command
      }
      hostname = container.networking == null ? null : container.networking.hostname
      links    = container.networking == null ? null : container.networking.links
    }
  ])
}

resource "aws_ecs_service" "rif" {
  name = var.service_name

  desired_count = var.task_count
  cluster       = data.aws_ecs_cluster.evergreen.id

  force_new_deployment = true
  task_definition      = aws_ecs_task_definition.rif.arn

  launch_type         = "EC2"
  scheduling_strategy = "REPLICA"

  load_balancer {
    container_name   = var.target_group_container_name
    container_port   = var.target_group_container_port
    target_group_arn = aws_lb_target_group.this.arn
  }
}
