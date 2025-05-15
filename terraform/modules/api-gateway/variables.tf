variable "env_prefix" {
  description = "Environment prefix for naming"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "vpc_link_subnets" {
  description = "List of subnet IDs for VPC link"
  type        = list(string)
}

variable "alb_dns_name" {
  description = "ALB DNS name"
  type        = string
}

variable "alb_listener_arn" {
  description = "ALB listener ARN"
  type        = string
}

variable "alb_arn" {
  description = "ALB ARN"
  type        = string
}

variable "private_route_paths" {
  description = "List of private route paths"
  type        = list(string)
}

variable "public_route_paths" {
  description = "List of public route paths"
  type        = list(string)
}

variable "vpc_link_target_arn" {
  description = "ARN of the NLB for VPC Link"
  type        = string
}