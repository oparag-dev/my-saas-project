locals {
  tenant_limits_json = jsonencode(var.tenant_limits)
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../../../src/lambda"
  output_path = "${path.module}/../../../build/${var.function_name}.zip"
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = 7
}

resource "aws_iam_role" "exec" {
  name = "${var.function_name}-exec"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "exec_policy" {
  name = "${var.function_name}-policy"
  role = aws_iam_role.exec.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "${aws_cloudwatch_log_group.this.arn}:*"
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query"
        ]
        Resource = [
          "arn:aws:dynamodb:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:table/${var.dynamodb_table_name}",
          "arn:aws:dynamodb:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:table/${var.dynamodb_table_name}/index/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:AbortMultipartUpload"
        ]
        Resource = "arn:aws:s3:::${var.audit_bucket_name}/*"
      }
    ]
  })
}

resource "aws_lambda_function" "this" {
  function_name = var.function_name
  role          = aws_iam_role.exec.arn
  runtime       = "python3.12"
  handler       = "app.handler"
  memory_size   = 128
  timeout       = 10

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      ENVIRONMENT        = var.environment
      DYNAMODB_TABLE     = var.dynamodb_table_name
      AUDIT_BUCKET       = var.audit_bucket_name
      TENANT_LIMITS_JSON = local.tenant_limits_json
      USER_POOL_ID       = var.user_pool_id
    }
  }

  depends_on = [aws_cloudwatch_log_group.this]
}