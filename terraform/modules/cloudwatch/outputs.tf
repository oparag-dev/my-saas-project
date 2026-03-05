output "lambda_alarm_name" {
  value = aws_cloudwatch_metric_alarm.lambda_errors.alarm_name
}

output "api_alarm_name" {
  value = aws_cloudwatch_metric_alarm.api_5xx.alarm_name
}

output "dynamodb_alarm_name" {
  value = aws_cloudwatch_metric_alarm.dynamodb_throttle.alarm_name
}