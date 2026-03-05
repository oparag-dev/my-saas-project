variable "aws_region" {
  type    = string
  default = "eu-west-3"
}

variable "environment" {
  type = string
}

variable "lambda_function_name" {
  type = string
}

variable "lambda_code_bucket" {
  type = string
}

variable "tenant_limits" {
  type        = map(number)
  description = "Tenant tier limits, e.g., max report window, max API calls"
}

variable "dynamodb_table_name" {
  type = string
}

variable "api_name" {
  type = string
}

variable "s3_audit_bucket" {
  type = string
}

variable "audit_glacier_days" {
  type    = number
  default = 90
}

variable "user_pool_name" {
  type = string
}

variable "app_client_name" {
  type = string
}