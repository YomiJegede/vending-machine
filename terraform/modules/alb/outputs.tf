output "alb_dns_name" {
  value = aws_lb.main.dns_name
}

output "alb_target_group_arn" {
  value = aws_lb_target_group.app.arn
}

output "alb_listener_arn" {
  value = aws_lb_listener.http.arn
}

output "alb_arn" {
  value = aws_lb.main.arn
}