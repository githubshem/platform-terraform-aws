locals {
  broker_name = var.broker_name != "" ? var.broker_name : "plat-${var.environment}-rabbitmq-cluster"

  default_tags = var.manage_default_tags ? {
    Name      = local.broker_name
    ManagedBy = "terraform"
  } : {}
}

resource "aws_mq_broker" "rabbitmq" {
  broker_name        = local.broker_name
  engine_type        = "RabbitMQ"
  engine_version     = var.engine_version
  host_instance_type = var.host_instance_type
  deployment_mode    = var.deployment_mode

  auto_minor_version_upgrade = var.auto_minor_version_upgrade

  subnet_ids      = var.subnet_ids
  security_groups = var.security_groups

  publicly_accessible = false

  user {
    username = var.admin_username
    password = var.admin_password
  }

  # Attach an existing broker configuration when provided (e.g. imported brokers).
  dynamic "configuration" {
    for_each = var.configuration_id != "" ? [1] : []
    content {
      id       = var.configuration_id
      revision = var.configuration_revision
    }
  }

  # Use a customer-managed KMS key when provided; otherwise AWS-owned key.
  dynamic "encryption_options" {
    for_each = var.kms_key_id != "" ? [1] : []
    content {
      kms_key_id        = var.kms_key_id
      use_aws_owned_key = false
    }
  }

  maintenance_window_start_time {
    day_of_week = var.maintenance_day
    time_of_day = var.maintenance_time
    time_zone   = "UTC"
  }

  logs {
    general = var.enable_general_logs
  }

  tags = merge(var.project_tags, local.default_tags)
}
