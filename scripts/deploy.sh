#!/bin/bash
set -e  # Exit immediately if any command fails

# Build and push Docker image
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
AWS_REGION=$(aws configure get region)
ECR_REPO="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/beverage-vending-repo"

echo "=== Building and pushing Docker image ==="

# Login to ECR
aws ecr get-login-password | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

# Create ECR repository if not exists
if ! aws ecr describe-repositories --repository-names beverage-vending-repo >/dev/null 2>&1; then
  echo "Creating ECR repository..."
  aws ecr create-repository --repository-name beverage-vending-repo
fi

# Build and push image
echo "Building Docker image..."
docker build -t beverage-vending-machine .

echo "Tagging and pushing image to ECR..."
docker tag beverage-vending-machine:latest ${ECR_REPO}:latest
docker push ${ECR_REPO}:latest

echo "=== Docker image pushed successfully ==="

# Terraform deployment
cd terraform
echo -e "\n=== Initializing Terraform ==="
terraform init

echo -e "\n=== Reviewing Terraform Plan ==="
terraform plan -var="aws_account_id=${AWS_ACCOUNT_ID}"

read -p "Do you want to apply these changes? (yes/no): " confirm
if [[ $confirm == "yes" ]]; then
  echo -e "\n=== Applying Terraform Changes ==="
  terraform apply -var="aws_account_id=${AWS_ACCOUNT_ID}"
else
  echo -e "\n=== Deployment cancelled by user ==="
  exit 0
fi

echo -e "\n=== Deployment completed successfully ==="