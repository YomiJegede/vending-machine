#!/bin/bash
set -euo pipefail  # Strict error handling

# Color definitions for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

function log_error() {
  echo -e "${RED}[ERROR] $1${NC}" >&2
}

function log_success() {
  echo -e "${GREEN}[SUCCESS] $1${NC}"
}

function log_warning() {
  echo -e "${YELLOW}[WARNING] $1${NC}"
}

function log_info() {
  echo -e "[INFO] $1"
}

# Validate AWS credentials
function validate_aws_credentials() {
  log_info "Validating AWS credentials..."
  if ! aws sts get-caller-identity >/dev/null 2>&1; then
    log_error "AWS credentials not configured or invalid"
    exit 1
  fi
}

# Docker image handling
function handle_docker() {
  log_info "=== Docker Image Handling ==="

  AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
  AWS_REGION=$(aws configure get region)
  ECR_REPO="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/beverage-vending-repo"

  # ECR Login
  log_info "Logging into ECR..."
  if ! aws ecr get-login-password | docker login --username AWS --password-stdin "${ECR_REPO}" >/dev/null; then
    log_error "Failed to login to ECR"
    exit 1
  fi

  # Ensure repository exists
  log_info "Checking ECR repository..."
  if ! aws ecr describe-repositories --repository-names beverage-vending-repo >/dev/null 2>&1; then
    log_info "Creating ECR repository..."
    if ! aws ecr create-repository --repository-name beverage-vending-repo >/dev/null; then
      log_error "Failed to create ECR repository"
      exit 1
    fi
  fi

  # Ensure buildx builder exists
  if ! docker buildx inspect multi-builder >/dev/null 2>&1; then
    log_info "Creating Docker Buildx builder..."
    docker buildx create --name multi-builder --use
  else
    docker buildx use multi-builder
  fi

  # Build and push for linux/amd64 to support fargate
  log_info "Building Docker image for linux/amd64..."
  if ! docker buildx build \
    --platform linux/amd64 \
    -t "${ECR_REPO}:latest" \
    -f ../Dockerfile \
    ../ \
    --push; then
    log_error "Docker build or push failed"
    exit 1
  fi

  log_success "Docker image successfully built and pushed to ECR"
}

# Terraform deployment
function handle_terraform() {
  log_info "=== Terraform Deployment ==="
  
  cd ../terraform || { log_error "Failed to enter terraform directory"; exit 1; }

  # Terraform Init
  log_info "Initializing Terraform..."
  if ! terraform init -input=false; then
    log_error "Terraform init failed"
    exit 1
  fi

  # Terraform Plan
  log_info "Creating execution plan..."
  terraform plan -var="aws_account_id=${AWS_ACCOUNT_ID}" -input=false -out=tfplan
  if [ $? -ne 0 ]; then
    log_error "Terraform plan failed"
    exit 1
  fi

  # User Confirmation
  echo -e "\n"
  read -p "Do you want to apply these changes? (yes/no): " confirm
  if [[ "$confirm" != "yes" ]]; then
    log_warning "Deployment cancelled by user"
    exit 0
  fi

  # Terraform Apply
  log_info "Applying changes..."
  if ! terraform apply -input=false tfplan; then
    log_error "Terraform apply failed"
    exit 1
  fi

  log_success "Deployment completed successfully"
}

# Main execution
function main() {
  validate_aws_credentials
  handle_docker
  handle_terraform
}

main "$@"
