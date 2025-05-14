resource "aws_ecs_cluster" "main" {
  name = "${var.env_prefix}-cluster"
}

resource "aws_ecs_task_definition" "app" {
  family                   = "${var.env_prefix}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = var.ecs_task_execution_role_arn

  container_definitions = jsonencode([{
    name      = "${var.env_prefix}-container"
    image     = var.container_image
    essential = true
    portMappings = [{
      containerPort = 3000
      hostPort      = 3000
    }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = "/ecs/${var.env_prefix}-task"
        "awslogs-region"        = var.aws_region
        "awslogs-stream-prefix" = "ecs"
      }
    }
  }])
}

resource "aws_ecs_service" "main" {
  name            = "${var.env_prefix}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnets
    security_groups  = [var.ecs_security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.alb_target_group_arn  # ALB for public routes
    container_name   = "${var.env_prefix}-container"
    container_port   = 3000
  }

  dynamic "load_balancer" {
    for_each = var.nlb_target_group_arn != "" ? [1] : []
    content {
      target_group_arn = var.nlb_target_group_arn
      container_name   = "${var.env_prefix}-container"
      container_port   = 3000
    }
  }
}