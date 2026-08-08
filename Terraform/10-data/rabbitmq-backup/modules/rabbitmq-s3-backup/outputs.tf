output "s3_bucket_name" {
  description = "Name of the S3 bucket storing RabbitMQ backups"
  value       = aws_s3_bucket.rabbitmq_backup.bucket
}

output "s3_bucket_arn" {
  description = "ARN of the S3 backup bucket"
  value       = aws_s3_bucket.rabbitmq_backup.arn
}

output "lambda_function_name" {
  description = "Name of the Lambda function that performs the backup"
  value       = aws_lambda_function.rabbitmq_backup.function_name
}

output "lambda_function_arn" {
  description = "ARN of the backup Lambda function"
  value       = aws_lambda_function.rabbitmq_backup.arn
}

output "iam_role_arn" {
  description = "ARN of the IAM role used by the backup Lambda"
  value       = aws_iam_role.backup_lambda.arn
}

output "eventbridge_rule_name" {
  description = "Name of the EventBridge schedule rule"
  value       = aws_cloudwatch_event_rule.backup_schedule.name
}

output "cloudwatch_log_group" {
  description = "CloudWatch Log Group name for backup Lambda logs"
  value       = aws_cloudwatch_log_group.backup_logs.name
}
