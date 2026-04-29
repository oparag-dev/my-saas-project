#!/bin/bash
set -e

echo "Deploying infrastructure..."

./scripts/package-lambda.sh

cd terraform/root

terraform fmt -recursive
terraform validate
terraform plan -var-file=dev.tfvars
terraform apply -var-file=dev.tfvars

echo "Deployment complete."