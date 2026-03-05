output "lambda_arn" {
  value = module.lambda.lambda_arn
}

output "dynamodb_table_name" {
  value = module.dynamodb.table_name
}

output "api_gateway_url" {
  value = module.api_gateway.api_endpoint
}

output "s3_audit_bucket" {
  value = module.s3_audit.bucket_name
}

output "cognito_user_pool_id" {
  value = module.cognito.user_pool_id
}