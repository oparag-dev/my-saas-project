environment = "dev"
lambda_function_name = "multi_tenant_handler_dev"
lambda_code_bucket   = "my-saas-lambda-code-dev"
dynamodb_table_name  = "saas_transactions_dev"
api_name             = "saas-api-dev"
s3_audit_bucket      = "saas-audit-logs-dev"
user_pool_name       = "saas-user-pool-dev"
app_client_name      = "saas-app-client-dev"
tenant_limits = {
  basic = 30
  growth = 90
  pro = 180
}