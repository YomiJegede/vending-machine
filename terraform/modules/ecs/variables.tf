variable "env_prefix" {
  description = "Environment prefix for naming"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnets" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "ecs_task_cpu" {
  description = "CPU units for ECS task"
  type        = number
}

variable "ecs_task_memory" {
  description = "Memory for ECS task in MB"
  type        = number
}

variable "ecs_task_execution_role_arn" {
  description = "ECS task execution role ARN"
  type        = string
}

variable "container_image" {
  description = "Container image URI"
  type        = string
}

variable "alb_target_group_arn" {
  description = "ALB target group ARN"
  type        = string
}

variable "ecs_security_group_id" {
  description = "Security group ID for ECS tasks"
  type        = string
}

variable "nlb_target_group_arn" {
  description = "ARN of the NLB target group for VPC Link"
  type        = string
  default     = "" # Make optional if not all environments need it
}