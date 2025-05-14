resource "aws_appautoscaling_target" "ecs" {
  max_capacity       = 4
  min_capacity       = 1
  service_namespace  = "ecs"
  scalable_dimension = "ecs:service:DesiredCount"

  # Automatically wait for ECS service to exist
  resource_id = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.main.name}"

  depends_on = [aws_ecs_service.main]
}

resource "aws_appautoscaling_policy" "ecs_cpu" {
  name               = "${var.env_prefix}-cpu-autoscaling-policy"
  policy_type        = "TargetTrackingScaling"
  service_namespace  = aws_appautoscaling_target.ecs.service_namespace
  resource_id        = aws_appautoscaling_target.ecs.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs.scalable_dimension

  target_tracking_scaling_policy_configuration {
    target_value       = 70.0  # target average CPU usage %
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    scale_in_cooldown  = 70
    scale_out_cooldown = 70
  }
}

#  Memory-based scaling policy
resource "aws_appautoscaling_policy" "ecs_memory" {
  name               = "${var.env_prefix}-memory-autoscaling-policy"
  policy_type        = "TargetTrackingScaling"
  service_namespace  = aws_appautoscaling_target.ecs.service_namespace
  resource_id        = aws_appautoscaling_target.ecs.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs.scalable_dimension

  target_tracking_scaling_policy_configuration {
    target_value       = 70.0  # target average memory usage %
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
    scale_in_cooldown  = 70
    scale_out_cooldown = 70
  }
}
