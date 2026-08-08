variable "environment" {
  description = "Environment name (test or prod)"
  type        = string

  validation {
    condition     = contains(["test", "prod"], var.environment)
    error_message = "environment must be one of: test, prod."
  }
}

variable "aws_region" {
  description = "AWS region where resources are deployed"
  type        = string
  default     = "ap-southeast-1"
}

variable "broker_type" {
  description = "Type of RabbitMQ deployment: 'amazon_mq' (AWS managed) or 'ecs' (self-hosted)"
  type        = string

  validation {
    condition     = contains(["amazon_mq", "ecs"], var.broker_type)
    error_message = "broker_type must be either 'amazon_mq' or 'ecs'."
  }
}

variable "broker_name" {
  description = "Logical name for the broker - used as CLUSTER_NAME in backup scripts and S3 key paths"
  type        = string
}

variable "amazon_mq_broker_id" {
  description = "Amazon MQ Broker ID - required when broker_type is 'amazon_mq'"
  type        = string
  default     = ""
}

variable "mgmt_host" {
  description = "Full management API URL for ECS broker - required when broker_type is 'ecs' (e.g. http://internal-alb:15672)"
  type        = string
  default     = ""
}

variable "secret_name" {
  description = "AWS Secrets Manager secret name (not ARN). E.g. 'shared-ssm/zeus/credentials'"
  type        = string
}

variable "username_key" {
  description = "Key inside the Secrets Manager secret JSON holding the RabbitMQ username"
  type        = string
}

variable "password_key" {
  description = "Key inside the Secrets Manager secret JSON holding the RabbitMQ password"
  type        = string
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket to store RabbitMQ definition backups"
  type        = string
}

variable "s3_prefix" {
  description = "S3 key prefix for backup objects (default: 'rabbitmq-definitions')"
  type        = string
  default     = "rabbitmq-definitions"
}

variable "backup_schedule" {
  description = "EventBridge cron schedule expression. Default: 2 AM UTC daily."
  type        = string
  default     = "cron(0 2 * * ? *)"
}

variable "retention_days" {
  description = "Number of days to retain backup files in S3 before expiry"
  type        = number
  default     = 90

  validation {
    condition     = var.retention_days >= 1
    error_message = "retention_days must be at least 1."
  }
}

variable "project_tag" {
  description = "Jira ticket identifier applied as a Project tag on all resources"
  type        = string
  default     = "rabbitmq-s3-backup"
}

variable "tags" {
  description = "Additional tags to merge onto all resources"
  type        = map(string)
  default     = {}
}
