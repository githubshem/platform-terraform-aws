# 1. Required Variables (Must be provided in .tfvars)
variable "replication_group_id" { type = string }
variable "engine_version" { type = string }
variable "node_type" { type = string }
variable "parameter_group_name" { type = string }
variable "private_subnet_ids" { type = list(string) }
variable "subnet_group_name" { type = string }
variable "security_group_ids" { type = list(string) }

# 2. Optional Variables (Have defaults, can be overridden in .tfvars)
variable "description" {
  type    = string
  default = "Managed by Terraform"
}

# Total number of nodes in the (non-clustered) group, including the primary.
# 2 = 1 primary + 1 replica.
variable "num_cache_clusters" {
  type    = number
  default = 2
}

variable "automatic_failover_enabled" {
  type    = bool
  default = true
}

variable "multi_az_enabled" {
  type    = bool
  default = true
}

variable "at_rest_encryption_enabled" {
  type    = bool
  default = true
}

variable "transit_encryption_enabled" {
  type    = bool
  default = false
}

variable "port" {
  type    = number
  default = 6379
}

# Name of an existing ElastiCache snapshot/backup to restore from.
# Leave empty ("") to create a fresh cluster instead of restoring.
variable "snapshot_name" {
  type    = string
  default = ""
}

# Set to false to reuse an existing subnet group instead of creating one.
variable "create_subnet_group" {
  type    = bool
  default = true
}

variable "snapshot_retention_limit" {
  type    = number
  default = 7
}

variable "snapshot_window" {
  type    = string
  default = "03:00-05:00"
}

variable "maintenance_window" {
  type    = string
  default = "sun:05:00-sun:07:00"
}

# Name for the final snapshot taken on deletion. Leave empty ("") to skip.
variable "final_snapshot_identifier" {
  type    = string
  default = ""
}

variable "apply_immediately" {
  type    = bool
  default = true
}

variable "tags" {
  type    = map(string)
  default = {}
}
