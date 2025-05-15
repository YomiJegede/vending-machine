resource "aws_cloudwatch_log_group" "ecs_task_log_group" {
  name              = "/ecs/${var.env_prefix}-task"
  retention_in_days = 7
}

resource "aws_ecs_cluster" "main" {
  name = "${var.env_prefix}-cluster"
}

# IAM Role for ECS Exec
resource "aws_iam_role" "ecs_exec_role" {
  name = "${var.env_prefix}-ecs-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

# Attach required AWS managed policies for ECS Exec and SSM
resource "aws_iam_role_policy_attachment" "ecs_exec" {
  role       = aws_iam_role.ecs_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ssm_exec" {
  role       = aws_iam_role.ecs_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# ECS Task Definition
resource "aws_ecs_task_definition" "app" {
  family                   = "${var.env_prefix}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512

  # Use ECS Exec IAM Role for execution and task
  execution_role_arn = aws_iam_role.ecs_exec_role.arn
  task_role_arn      = aws_iam_role.ecs_exec_role.arn

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
        awslogs-group         = aws_cloudwatch_log_group.ecs_task_log_group.name
        awslogs-region        = var.aws_region
        awslogs-stream-prefix = "ecs"
      }
    }
  }])
}

# ECS Service with Exec enabled
resource "aws_ecs_service" "main" {
  name            = "${var.env_prefix}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  # Enable ECS Exec on the service
  enable_execute_command = true

  network_configuration {
    subnets          = var.private_subnets
    security_groups  = [var.ecs_security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.alb_target_group_arn
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
