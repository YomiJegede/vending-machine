variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "azs" {
  description = "A list of availability zones in the region"
  type        = list(string)
}

variable "env_prefix" {
  description = "Environment prefix for resource naming and tagging"
  type        = string
}

# Security Group Variables
variable "app_port" {
  description = "Port exposed by the application"
  type        = number
  default     = 3000
}

variable "health_check_path" {
  description = "Path for health check endpoint"
  type        = string
  default     = "/health"
}