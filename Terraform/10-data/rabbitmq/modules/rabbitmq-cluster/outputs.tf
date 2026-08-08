output "broker_id" {
  description = "Amazon MQ broker ID"
  value       = aws_mq_broker.rabbitmq.id
}

output "broker_arn" {
  description = "Amazon MQ broker ARN"
  value       = aws_mq_broker.rabbitmq.arn
}

output "instances_endpoints" {
  description = "AMQP+SSL endpoint list per broker node"
  value       = aws_mq_broker.rabbitmq.instances[*].endpoints
}

output "console_url" {
  description = "RabbitMQ management console URL"
  value       = aws_mq_broker.rabbitmq.instances[0].console_url
}

output "broker_name" {
  description = "Full broker name as provisioned in AWS"
  value       = aws_mq_broker.rabbitmq.broker_name
}

output "broker_console_endpoint" {
  description = "RabbitMQ management console URL (used for /api/definitions backups)"
  value       = aws_mq_broker.rabbitmq.instances[0].console_url
}
