variable "env_prefix" {
  description = "Environment prefix for naming"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "public_subnets" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "alb_security_groups" {
  description = "List of ALB security group IDs"
  type        = list(string)
}