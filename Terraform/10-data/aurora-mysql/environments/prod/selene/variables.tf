# 1. Required Variables (Must be provided in .tfvars)
variable "cluster_identifier" { type = string }
variable "instance_names" { type = list(string) }
variable "rds_username" { type = string }
variable "secret_name" { type = string }
variable "rds_instance_class" { type = string }
variable "backup_retention_days" { type = number }
variable "deletion_protection" { type = bool }
variable "skip_final_snapshot" { type = bool }
variable "cluster_parameter_group_name" { type = string }
variable "db_parameter_group_name" { type = string }
variable "iam_database_authentication_enabled" { type = bool }
variable "performance_insights_enabled" { type = bool }
variable "autoscaling_enabled" { type = bool }

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
