variable "vpc_id" {
  description = "VPC ID where NLB will be deployed"
  type        = string
}

variable "private_subnets" {
  description = "List of private subnet IDs for NLB"
  type        = list(string)
}

variable "env_prefix" {
  description = "Environment prefix for resource naming"
  type        = string
}