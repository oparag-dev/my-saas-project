#!/usr/bin/env bash
set -euo pipefail

ENVIRONMENT="${1:-dev}"
AWS_REGION="${AWS_REGION:-eu-west-3}"

if [ "$ENVIRONMENT" != "dev" ]; then
  echo "Refusing to run destroy script for environment: $ENVIRONMENT"
  echo "This script is currently allowed for dev only."
  exit 1
fi

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TERRAFORM_ROOT="$PROJECT_ROOT/terraform/root"
TFVARS_FILE="$PROJECT_ROOT/terraform/envs/${ENVIRONMENT}.tfvars"

if [ ! -f "$TFVARS_FILE" ]; then
  echo "Missing tfvars file: $TFVARS_FILE"
  exit 1
fi

AUDIT_BUCKET=$(grep '^s3_audit_bucket' "$TFVARS_FILE" | cut -d '=' -f2 | tr -d ' "')

if [ -z "$AUDIT_BUCKET" ]; then
  echo "Could not read s3_audit_bucket from $TFVARS_FILE"
  exit 1
fi

echo "Environment: $ENVIRONMENT"
echo "Region: $AWS_REGION"
echo "Audit bucket: $AUDIT_BUCKET"
echo ""

read -p "This will empty the audit bucket and run terraform destroy. Continue? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
  echo "Destroy cancelled."
  exit 0
fi

echo "Emptying current objects from s3://$AUDIT_BUCKET..."
aws s3 rm "s3://$AUDIT_BUCKET" --recursive --region "$AWS_REGION" || true

echo "Deleting object versions from s3://$AUDIT_BUCKET..."
VERSIONS_FILE="/tmp/${AUDIT_BUCKET}-versions.json"

aws s3api list-object-versions \
  --bucket "$AUDIT_BUCKET" \
  --region "$AWS_REGION" \
  --query='{Objects: Versions[].{Key:Key,VersionId:VersionId}}' \
  --output json > "$VERSIONS_FILE"

if grep -q '"Objects": null' "$VERSIONS_FILE"; then
  echo "No object versions found."
else
  aws s3api delete-objects \
    --bucket "$AUDIT_BUCKET" \
    --region "$AWS_REGION" \
    --delete "file://$VERSIONS_FILE"
fi

echo "Deleting delete markers from s3://$AUDIT_BUCKET..."
MARKERS_FILE="/tmp/${AUDIT_BUCKET}-delete-markers.json"

aws s3api list-object-versions \
  --bucket "$AUDIT_BUCKET" \
  --region "$AWS_REGION" \
  --query='{Objects: DeleteMarkers[].{Key:Key,VersionId:VersionId}}' \
  --output json > "$MARKERS_FILE"

if grep -q '"Objects": null' "$MARKERS_FILE"; then
  echo "No delete markers found."
else
  aws s3api delete-objects \
    --bucket "$AUDIT_BUCKET" \
    --region "$AWS_REGION" \
    --delete "file://$MARKERS_FILE"
fi

echo "Running terraform destroy..."
cd "$TERRAFORM_ROOT"
terraform destroy -var-file="$TFVARS_FILE"

echo "Destroy complete for environment: $ENVIRONMENT"
