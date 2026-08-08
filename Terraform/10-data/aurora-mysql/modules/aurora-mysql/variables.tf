# 1. Required Variables (Must be provided in .tfvars)
variable "cluster_identifier" { type = string }
variable "instance_names" { type = list(string) }
variable "snapshot_identifier" {
  type        = string
  default     = null
  description = <<-EOT
    Restore the cluster from an existing snapshot instead of creating an empty
    one. Defaults to null so a cluster builds from scratch; set it only for a
    genuine restore.
  EOT
}
variable "rds_username" { type = string }
variable "rds_password" { type = string }
variable "rds_instance_class" { type = string }
variable "private_subnet_ids" { type = list(string) }
variable "rds_vpc_security_group_ids" { type = list(string) }
variable "backup_retention_days" { type = number }
variable "deletion_protection" { type = bool }
variable "skip_final_snapshot" { type = bool }
variable "cluster_parameter_group_name" { type = string }
variable "db_parameter_group_name" { type = string }
variable "iam_database_authentication_enabled" { type = bool }
variable "performance_insights_enabled" { type = bool }
variable "performance_insights_retention_period" {
  type    = number
  default = 7
}
variable "autoscaling_enabled" { type = bool }

# Set to false to reuse an existing DB subnet group instead of creating one.
variable "create_db_subnet_group" {
  type    = bool
  default = true
}

# 2. Optional Variables (Have defaults, you can skip these in .tfvars)
variable "rds_engine_version" {
  type    = string
  default = "8.0.mysql_aurora.3.10.3"
}

variable "autoscaling_min" {
  type    = number
  default = 1
}

variable "autoscaling_max" {
  type    = number
  default = 3
}

variable "autoscaling_target_cpu" {
  type    = number
  default = 70
}
variable "db_subnet_group_name" { type = string }