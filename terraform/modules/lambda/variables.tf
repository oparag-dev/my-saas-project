variable "function_name" {
  type = string
}

variable "s3_bucket" {
  type = string
}

variable "s3_key" {
  description = "S3 key for Lambda zip"
  type        = string
}

variable "environment" {
  type = string
}

variable "tenant_limits" {
  type = map(number)
}

variable "dynamodb_table_name" {
  type = string
}

variable "audit_bucket_name" {
  type = string
}

variable "user_pool_id" {
  type = string
}