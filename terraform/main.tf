terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "network" {
  source     = "./modules/network"
  vpc_cidr   = var.vpc_cidr
  azs        = var.availability_zones
  env_prefix = var.environment_prefix
}

module "iam" {
  source     = "./modules/iam"
  env_prefix = var.environment_prefix
}

module "alb" {
  source              = "./modules/alb"
  vpc_id              = module.network.vpc_id
  public_subnets      = module.network.public_subnets
  env_prefix          = var.environment_prefix
  alb_security_groups = [module.network.alb_security_group_id]
}

module "ecs" {
  source                      = "./modules/ecs"
  vpc_id                      = module.network.vpc_id
  private_subnets             = module.network.private_subnets
  env_prefix                  = var.environment_prefix
  aws_region                  = var.aws_region
  ecs_task_cpu                = var.ecs_task_cpu
  ecs_task_memory             = var.ecs_task_memory
  ecs_task_execution_role_arn = module.iam.ecs_task_execution_role_arn
  container_image             = "${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${var.environment_prefix}-repo:latest"
  alb_target_group_arn        = module.alb.alb_target_group_arn
}

module "api_gateway" {
  source              = "./modules/api-gateway"
  vpc_id              = module.network.vpc_id
  vpc_link_subnets    = module.network.private_subnets
  alb_dns_name        = module.alb.alb_dns_name
  alb_listener_arn    = module.alb.alb_listener_arn
  alb_arn             = module.alb.alb_arn
  env_prefix          = var.environment_prefix
  private_route_paths = ["/ingredients"]
  public_route_paths  = ["/beverages"]
}