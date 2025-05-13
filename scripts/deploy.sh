#!/bin/bash

# Build and push Docker image
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
AWS_REGION=$(aws configure get region)
ECR_REPO="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/beverage-vending-repo"

# Login to ECR
aws ecr get-login-password | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

# Create ECR repository if not exists
aws ecr describe-repositories --repository-names beverage-vending-repo || aws ecr create-repository --repository-name beverage-vending-repo

# Build and push image
docker build -t beverage-vending-machine .
docker tag beverage-vending-machine:latest ${ECR_REPO}:latest
docker push ${ECR_REPO}:latest

# Apply Terraform
cd terraform
terraform init
terraform apply -auto-approve