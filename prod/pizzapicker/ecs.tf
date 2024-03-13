resource "aws_ecs_cluster" "ecs" {
  name = "pizzapicker"
}

resource "aws_ecs_cluster_capacity_providers" "fargate" {
  cluster_name       = aws_ecs_cluster.ecs.name
  capacity_providers = ["FARGATE_SPOT"]
  default_capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    base              = 0
    weight            = 100
  }
}

resource "aws_ecs_task_definition" "ecs" {
  family                   = "pizzapicker"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = "arn:aws:iam::891459268445:role/ecsTaskExecutionRole"
  task_role_arn            = aws_iam_role.ecs.arn

  container_definitions = jsonencode([
    {
      name      = "pizzapicker"
      cpu       = 256
      memory    = 512
      essential = true
      image     = "${module.ecr_repository.ecr_repository_url}:latest"
      environment = sensitive([
        for key, value in data.doppler_secrets.pizzapicker.map : {
          name  = key
          value = value
        }
      ])
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs.name
          awslogs-region        = "eu-north-1"
          awslogs-stream-prefix = "awslogs-pizzapicker"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "ecs" {
  name            = "pizzapicker"
  cluster         = aws_ecs_cluster.ecs.id
  task_definition = aws_ecs_task_definition.ecs.id

  scheduling_strategy = "REPLICA"
  launch_type         = "FARGATE"
  desired_count       = 1

  network_configuration {
    subnets          = [data.aws_subnet.default.id]
    assign_public_ip = true
  }
}
