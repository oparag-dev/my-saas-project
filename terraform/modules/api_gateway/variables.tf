variable "api_name" {
  description = "API Gateway name"
  type        = string
}

variable "lambda_arn" {
  description = "Lambda invoke ARN or function ARN"
  type        = string
}

variable "user_pool_arn" {
  description = "Cognito User Pool ARN for authorizer"
  type        = string
}
variable "lambda_function_name" {
  description = "Lambda function name"
  type        = string
}