variable "aws_region" {
  type    = string
  default = "ap-southeast-1"
}

# Identity
variable "replication_group_id" { type = string }
variable "description" { type = string }

# Hardware & Versioning
variable "engine_version" { type = string }
variable "node_type" { type = string }
variable "port" {
  type    = number
  default = 6379
}

# Topology
variable "num_cache_clusters" { type = number }
variable "automatic_failover_enabled" { type = bool }
variable "multi_az_enabled" { type = bool }

# Encryption
variable "at_rest_encryption_enabled" { type = bool }
variable "transit_encryption_enabled" { type = bool }

# Parameters
variable "parameter_group_name" { type = string }

# Networking

# Backup / Restore
variable "snapshot_retention_limit" { type = number }
variable "snapshot_window" { type = string }
variable "maintenance_window" { type = string }
variable "final_snapshot_identifier" { type = string }

variable "apply_immediately" { type = bool }
variable "tags" { type = map(string) }