output "api_gateway_url" {
  description = "Base URL for API Gateway"
  value       = module.api_gateway.api_gateway_url
}

output "private_endpoint_url" {
  description = "URL for private endpoint (accessible within VPC)"
  value       = module.alb.alb_dns_name
}

output "ecs_service_name" {
  description = "Name of the ECS service"
  value       = module.ecs.ecs_service_name
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.network.vpc_id
}