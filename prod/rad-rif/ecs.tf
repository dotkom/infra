resource "aws_ecs_task_definition" "rif" {
  family = "monoweb-prod-rif"

  requires_compatibilities = ["EC2"]
  network_mode             = "bridge"
  cpu                      = "256"
  memory                   = "256"
  execution_role_arn       = data.aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([
    {
      name      = "monoweb-prod-rif"
      image     = data.aws_ecr_image.rif.image_uri
      cpu       = 256
      memory    = 256
      essential = true
      environment = [
        for key, value in data.doppler_secrets.rif.map : {
          name  = key
          value = value
        }
      ]
      portMappings = [
        {
          containerPort = 3000
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.rif.name
          awslogs-region        = "eu-north-1"
          awslogs-stream-prefix = "ecs"
        }
      }
      healthCheck = {
        command = ["CMD-SHELL", "curl -f http://0.0.0.0:3000 || exit 1"]
      }
    }
  ])
}

resource "aws_ecs_service" "rif" {
  name = "monoweb-prod-rif"

  desired_count = 1
  cluster       = data.aws_ecs_cluster.evergreen.id

  force_new_deployment = true
  task_definition      = aws_ecs_task_definition.rif.arn

  launch_type         = "EC2"
  scheduling_strategy = "REPLICA"

  load_balancer {
    container_name   = "monoweb-prod-rif"
    container_port   = 3000
    target_group_arn = aws_lb_target_group.rif.arn
  }
}
