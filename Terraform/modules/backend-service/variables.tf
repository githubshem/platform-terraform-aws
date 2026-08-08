variable "environment" {}
variable "aws_region" {}
variable "cluster_id" {}
variable "cluster_name" { type = string }
variable "service_name" {}
variable "compute_type" {}
variable "compute_provider" {}
variable "cpu" { type = number }
variable "memory" { type = number }
variable "task_count" { type = number }
variable "port" { type = number }
variable "image_url" {}
variable "private_subnets" { type = list(string) }
variable "security_group_id" {}
variable "execution_role_arn" {}
variable "task_role_arn" {}
variable "capacity_provider" {
  description = "The specific capacity provider for this service (leave blank for default)"
  type        = string
  default     = "" # THIS IS CRITICAL to prevent errors when it's left blank
}
variable "az_rebalancing" {
  description = "Indicates whether to use Availability Zone rebalancing for the service. Valid values are ENABLED and DISABLED."
  type        = string
  default     = "DISABLED"
}

# --- NEW VARIABLES ADDED HERE ---
variable "memory_reservation" { type = number }
variable "host_volume_name" { type = string }
variable "host_volume_path" { type = string }
variable "env_vars" { type = map(string) }
variable "target_group_arn" {
  type        = list(string)
  default     = []
  description = "List of ALB Target Group ARNs to connect this service to (one load_balancer block per ARN)"
}

variable "cloudwatch_retention_days" { default = 30 }
variable "cp_weight" { default = 100 }
variable "max_capacity" { default = 10 }
variable "cpu_target_value" { default = 65.0 }
variable "scale_out_cooldown" { default = 180 }
variable "scale_in_cooldown" { default = 240 }
variable "placement_strategy_type" { default = "binpack" }
variable "placement_strategy_field" { default = "attribute:ecs.availability-zone" }

variable "app_prefix" {
  description = <<-EOT
    Application family this cluster belongs to, e.g. zeus or hera. It is the
    literal first segment of every resource name this module creates. This module
    used to exist as two byte-identical copies differing only in that literal,
    so changing the value renames real infrastructure -- it is not cosmetic.
  EOT
  type        = string
}

