resource "aws_lb" "vpc_link_nlb" {
  name               = "${var.env_prefix}-vpc-link-nlb"
  load_balancer_type = "network"
  internal           = true
  subnets            = var.private_subnets  # Now using the variable

  tags = {
    Name = "${var.env_prefix}-vpc-link-nlb"
  }
}

resource "aws_lb_target_group" "vpc_link" {
  name        = "${var.env_prefix}-vpc-link-tg"
  port        = 3000  # Must match container port
  protocol    = "TCP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    protocol            = "TCP"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "vpc_link" {
  load_balancer_arn = aws_lb.vpc_link_nlb.arn
  port              = 3000
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.vpc_link.arn
  }
}