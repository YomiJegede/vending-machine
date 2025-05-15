#!/bin/bash
set -euo pipefail 

echo "=== Infrastructure Destruction Script ==="
echo "This will PERMANENTLY delete all resources."

# Get AWS account info
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
AWS_REGION=$(aws configure get region)
ECR_REPO="beverage-vending-repo"

# Confirm destruction
read -p "Are you sure you want to DESTROY all infrastructure? (type 'destroy' to confirm): " confirmation
if [[ "$confirmation" != "destroy" ]]; then
    echo "Destruction cancelled."
    exit 1
fi

echo -e "\n=== Destroying Terraform Infrastructure ==="
cd ../terraform

# Show what will be destroyed
echo "Terraform destruction plan:"
terraform plan -destroy -var="aws_account_id=${AWS_ACCOUNT_ID}"

# Get confirmation again
read -p "Confirm FULL DESTRUCTION of above resources? (type 'yes' to continue): " final_confirmation
if [[ "$final_confirmation" != "yes" ]]; then
    echo "Destruction aborted."
    exit 1
fi

# Execute destruction
echo "Starting terraform destroy..."
terraform destroy -var="aws_account_id=${AWS_ACCOUNT_ID}"

echo -e "\n=== Cleaning Up ECR Repository ==="
# Check if repository exists
if aws ecr describe-repositories --repository-names "${ECR_REPO}" >/dev/null 2>&1; then
    echo "Deleting ECR repository..."
    aws ecr delete-repository \
        --repository-name "${ECR_REPO}" \
        --force
    echo "ECR repository deleted."
else
    echo "ECR repository not found - skipping deletion."
fi

echo -e "\n=== Cleanup Complete ==="
echo "All resources have been destroyed."