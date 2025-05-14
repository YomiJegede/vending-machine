output "nlb_arn" {
  value = aws_lb.vpc_link_nlb.arn
}

output "nlb_target_group_arn" {
  value = aws_lb_target_group.vpc_link.arn
}