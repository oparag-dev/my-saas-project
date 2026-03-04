# Provider
provider "aws" {
  region = var.aws_region
}

# Lambda Module
module "lambda" {
  source          = "../modules/lambda"
  function_name   = var.lambda_function_name
  s3_bucket       = var.lambda_code_bucket
  environment     = var.environment
  tenant_limits   = var.tenant_limits
}

# DynamoDB Module
module "dynamodb" {
  source       = "../modules/dynamodb"
  table_name   = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"
  point_in_time_recovery = true
}

# API Gateway Module
module "api_gateway" {
  source        = "../modules/api_gateway"
  api_name      = var.api_name
  lambda_arn    = module.lambda.lambda_arn
}

# S3 Module for audit logs
module "s3" {
  source          = "../modules/s3"
  bucket_name     = var.s3_audit_bucket
  lifecycle_days  = var.audit_glacier_days
}

# Cognito Module
module "cognito" {
  source            = "../modules/cognito"
  user_pool_name    = var.user_pool_name
  app_client_name   = var.app_client_name
}

# CloudWatch Module
module "cloudwatch" {
  source          = "../modules/cloudwatch"
  lambda_name     = module.lambda.lambda_name
  dynamodb_table  = module.dynamodb.table_name
  api_gateway_id  = module.api_gateway.api_id
}
