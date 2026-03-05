variable "lambda_function_name" {
  description = "Name of the Lambda function to monitor"
  type        = string
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table to monitor"
  type        = string
}

variable "api_gateway_id" {
  description = "API Gateway REST API ID to monitor"
  type        = string
}