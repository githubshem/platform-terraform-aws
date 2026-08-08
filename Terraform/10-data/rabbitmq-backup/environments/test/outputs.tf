output "amazon_mq_backup_bucket" {
  value = module.amazon_mq_backup.s3_bucket_name
}

output "amazon_mq_backup_lambda" {
  value = module.amazon_mq_backup.lambda_function_name
}

output "amazon_mq_log_group" {
  value = module.amazon_mq_backup.cloudwatch_log_group
}

output "ecs_backup_bucket" {
  value = module.ecs_rabbitmq_backup.s3_bucket_name
}

output "ecs_backup_lambda" {
  value = module.ecs_rabbitmq_backup.lambda_function_name
}

output "ecs_log_group" {
  value = module.ecs_rabbitmq_backup.cloudwatch_log_group
}
