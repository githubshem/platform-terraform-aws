variable "aws_region" { type = string }
variable "domain_name" { type = string }
variable "allowed_cidr_blocks" { type = list(string) }

# Data Node Setup
variable "instance_type" { type = string }
variable "instance_count" { type = number }

# Storage Setup
variable "ebs_enabled" { type = bool }
variable "ebs_volume_size" { type = number }
variable "ebs_volume_type" { type = string }
variable "ebs_iops" { type = number }
variable "ebs_throughput" { type = number }

# Security & Tags
variable "kms_key_arn" { type = string }
variable "master_user_name" { type = string }
variable "snapshot_hour" { type = number }
variable "access_policies" { type = string }
variable "project_tags" { type = map(string) }

# OpenSearch Dynamic Policies
# Multi-AZ & Master Node Toggles
variable "zone_awareness_enabled" { type = bool }
variable "dedicated_master_enabled" { type = bool }

# Optional Master Node Configuration (Defaults to null/0 when dedicated master nodes are not required)
variable "master_instance_type" {
  type    = string
  default = null
}

variable "master_instance_count" {
  type    = number
  default = 0
}