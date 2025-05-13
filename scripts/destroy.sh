#!/bin/bash

# Destroy Terraform infrastructure
cd terraform
terraform destroy -auto-approve

# Delete ECR repository
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
AWS_REGION=$(aws configure get region)
aws ecr delete-repository --repository-name beverage-vending-repo --force