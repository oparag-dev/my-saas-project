# 1. Cognito first, because API Gateway authorizer depends on it
module "cognito" {
  source          = "../modules/cognito"
  user_pool_name  = var.user_pool_name
  app_client_name = var.app_client_name
}

# 2. DynamoDB core data store
module "dynamodb" {
  source                 = "../modules/dynamodb"
  table_name             = var.dynamodb_table_name
  billing_mode           = "PAY_PER_REQUEST"
  point_in_time_recovery = true
}

# 3. S3 audit log bucket
module "s3_audit" {
  source         = "../modules/s3"
  bucket_name    = var.s3_audit_bucket
  lifecycle_days = var.audit_glacier_days
}

# 4. Lambda business logic
module "lambda" {
  source        = "../modules/lambda"
  function_name = var.lambda_function_name
  s3_bucket     = var.lambda_code_bucket
  s3_key        = "${var.lambda_function_name}.zip"

  environment   = var.environment
  tenant_limits = var.tenant_limits

  dynamodb_table_name = module.dynamodb.table_name
  audit_bucket_name   = module.s3_audit.bucket_name
  user_pool_id        = module.cognito.user_pool_id
}
# 5. API Gateway front door, with Cognito authorizer
module "api_gateway" {
  source = "../modules/api_gateway"

  api_name   = var.api_name
  lambda_arn = module.lambda.lambda_invoke_arn

  # For Cognito authorizer
  user_pool_arn = module.cognito.user_pool_arn

  depends_on = [module.cognito, module.lambda]
}

# 6. CloudWatch alarms and dashboards
module "cloudwatch" {
  source = "../modules/cloudwatch"

  lambda_function_name = module.lambda.lambda_name
  dynamodb_table_name  = module.dynamodb.table_name
  api_gateway_id       = module.api_gateway.api_id

  depends_on = [module.api_gateway]
}