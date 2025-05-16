# Beverage Vending Machine System

## Project Overview

This project aims to develop a system to manage a beverage vending machine. Each beverage has a recipe consisting of a list of ingredients. The system allows users to select a beverage, insert coins, specify the desired sugar level, and receive their beverage if sufficient ingredients are available.

## Features

1. **Beverage Selection**: Users can choose from a variety of beverages.
2. **Coin Insertion**: Users insert coins to pay for the selected beverage.
3. **Sugar Level Specification**: Users can specify the desired sugar level (from 1 to 5).
4. **Ingredient Check**: The system checks if there are enough ingredients to prepare the beverage.
5. **Beverage Dispensing**: If sufficient ingredients are available, the beverage is dispensed and change is returned.
6. **Transaction Propagation**: Successful transactions are propagated as a JSON object into BSV (Bitcoin SV).

## Design and Deployment

The deployment design and architecture for the beverage vending machine microservice is implemented on AWS using Terraform for infrastructure provisioning. Public and private endpoints are separated by routing public traffic through an Application Load Balancer (ALB) and private API requests through a Network Load Balancer (NLB) integrated with API Gateway VPC Link. The system operates within a VPC using private subnets, with a NAT Gateway enabling secure outbound internet access.

## Key Components
### Public Access
**API Gateway**: Exposes only /beverages to the internet

**HTTPS**: Automatic TLS termination

### Private Access
**NLB**: Handles VPC Link traffic for API Gateway

**ALB**: Internal routing for /ingredients

### Compute
**Fargate Tasks**: Containerized deployment of the microservice
	No EC2 instances
	SSM Exec for direct debugging
	Auto-scaling capability deployed

### Security
**Isolated Networking**:
	Private subnets + NAT Gateway/VPC endpoints

**IAM-Based Access**:
	SSM requires ecs:ExecuteCommand permissions

### Operational Tools
**SSM Session Manager**: Secure shell access without bastion hosts

**CloudWatch Logs**: Centralized logging and monitoring for all containers

### Scaling
**Horizontal Scaling**:
	ECS service auto-scaling based on CPU/memory usage

**Vertical Scaling**:
	Adjust Fargate task CPU/memory allocation

### Technologies Used
**Node.js**: For building RESTful APIs.

**AWS**: Comprehensive cloud services with good Terraform support

**Terraform**: Industry-standard IaC tool for reproducible infrastructure

**ECR (Elastic Container Registry)**: Docker images storage and ECS Fargate pulls images directly from ECR during task launch

**ECS Fargate**: Serverless containers simplify deployment and scaling

**API Gateway**: Flexible endpoint management with built-in security

**Docker**: Containerization ensures consistent runtime environment

**Shell Scripting**: To package the deployment and for de-provioning


## Architecture Overview 
### AWS Public Zone
    APIGateway --> [API Gateway --> Public endpoints --> beverages GET|POST/]
    End User -->|HTTPS| --> APIGateway

### AWS Private Zone
    APIGateway -->|VPC Link| NLB[Network Load Balancer --> Private only]
    
### VPC
     NLB -->|:3000| FargateTasks[ECS Fargate Tasks --> LaunchType=FARGATE --> SSM Exec access --> ingredients GET/]
      
      FargateTasks --> ALB[Application LB --> Internal --> Path-based routing]
      ALB -->|:3000| FargateTasks
      FargateTasks --> ECR[ECR Private Repo]
      SSM[SSM Session Manager] -->|Secure Shell| FargateTasks

	  Admin --> AWSCLI --> |SSM CLI| SSM

##  Setup Guide
### Prerequisites
1. AWS account with administrative privileges	
2. AWS CLI installed and configured - Default Region: eu-west-1 application is deployed in eu-west-1
3. Terraform version >= 3.40.0 required for Terraform AWS Provider to support enable_execute_command.
4. Docker installed
5. Node.js v18+ installed
6. AWS Systems Manager (SSM) Session Manager is enable to securely access ECS tasks in the private subnet
7. AWS CLI v2.2.0 and later is required for ecs execute-command
8. Install Session Manager Plugin - this is required for ecs execute-command to open the interactive session in AWSCLI


## Deployment Steps
1. Clone the Repository
	`git clone git@github.com:YomiJegede/vending-machine.git`

2. Navigate to the project directory

	`cd vending-machine/scripts`

3. Grant `deploy.sh` necesary permisions if needed `chmod +x deploy.sh` , Run deploy script and follow the on screen instructions

	`./deploy.sh`

4. On successful deployment, note the outputs for public and private endpoints and the VPC

	Example:

	`api_gateway_url = "https://ybxxezkhmb.execute-api.eu-west-1.amazonaws.com/test"`

    `ecs_service_name = "beverage-vending-service"`

    `private_endpoint_url = "beverage-vending-alb-189198045.eu-west-1.elb.amazonaws.com"`

    `vpc_id = "vpc-04a3b04acf51d3812"`

5. ## Test the end endpoints:
	### Public endpoints:
	#### Get API Gateway URL from outputs
	export API_URL="https://ybxxezkhmb.execute-api.eu-west-1.amazonaws.com/test"

	#### GET /beverages (public)
		curl "${API_URL}/beverages"

	#### POST /beverages request with JSON body
		curl -X POST "${API_URL}/beverages" \
  			-H "Content-Type: application/json" \
  			-d '{
    		"beverageName": "coffee",
    		"sugarLevel": 1,
    		"coins": [1, 1, 1]
  			}'
	### Private Endpoints: set TASK_ARN
  	`TASK_ARN=$(aws ecs list-tasks --cluster beverage-vending-cluster --query 'taskArns[0]' --output text)`

  	#### Connect to SSM:
		aws ecs execute-command \
  		--cluster beverage-vending-cluster \
  		--task $TASK_ARN \
 		--container beverage-vending-container \
  		--command "/bin/sh" \
  		--interactive

	#### Test the private ALB endpoint
      Get private_endpoint_url from outputs

		`curl -v "http://beverage-vending-alb-189198045.eu-west-1.elb.amazonaws.com/ingredients"`


6. Remember to destroy the deployment with `destroy.sh` script. Follow the on screen 		instructions.

   Grant `destroy.sh` necesary permisions if needed `chmod +x destroy.sh` , Run destroy script

    `cd vending-machine/scripts`

	`./destroy.sh`