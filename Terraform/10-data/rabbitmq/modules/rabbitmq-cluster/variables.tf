variable "environment" {
  description = "Environment name used in the broker name: plat-{environment}-rabbitmq-cluster"
  type        = string
}

variable "broker_name" {
  description = "Explicit broker name. When empty, falls back to plat-{environment}-rabbitmq-cluster."
  type        = string
  default     = ""
}

variable "engine_version" {
  description = "RabbitMQ engine version"
  type        = string
  default     = "3.13"
}

variable "host_instance_type" {
  description = "Amazon MQ instance type (e.g. mq.m5.large, mq.m7g.large)"
  type        = string
}

variable "deployment_mode" {
  description = "SINGLE_INSTANCE or CLUSTER_MULTI_AZ"
  type        = string
  default     = "CLUSTER_MULTI_AZ"

  validation {
    condition     = contains(["SINGLE_INSTANCE", "CLUSTER_MULTI_AZ"], var.deployment_mode)
    error_message = "deployment_mode must be SINGLE_INSTANCE or CLUSTER_MULTI_AZ."
  }
}

variable "subnet_ids" {
  description = "Subnet IDs. CLUSTER_MULTI_AZ requires 2 subnets in different AZs."
  type        = list(string)
}

variable "security_groups" {
  description = "Security group IDs to attach to the broker"
  type        = list(string)
}

variable "admin_username" {
  description = "RabbitMQ admin username"
  type        = string
}

variable "admin_password" {
  description = "RabbitMQ admin password (min 12 chars)"
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.admin_password) >= 12
    error_message = "admin_password must be at least 12 characters."
  }
}

variable "maintenance_day" {
  description = "Day of week for the maintenance window"
  type        = string
  default     = "SUNDAY"
}

variable "maintenance_time" {
  description = "Start time for maintenance window (UTC HH:MM)"
  type        = string
  default     = "03:00"
}

variable "project_tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "auto_minor_version_upgrade" {
  description = "Whether to enable automatic minor version upgrades"
  type        = bool
  default     = true
}

variable "enable_general_logs" {
  description = "Enable RabbitMQ general logs to CloudWatch"
  type        = bool
  default     = true
}

variable "manage_default_tags" {
  description = "When true, inject Name and ManagedBy tags. Set false to match resources that have no tags (e.g. imported brokers)."
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "Customer-managed KMS key ARN for at-rest encryption. Empty means AWS-owned key."
  type        = string
  default     = ""
}

variable "configuration_id" {
  description = "Existing broker configuration id to attach. Empty means none."
  type        = string
  default     = ""
}

variable "configuration_revision" {
  description = "Revision of the broker configuration referenced by configuration_id."
  type        = number
  default     = null
}
