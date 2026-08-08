variable "domain_name" { type = string }
variable "vpc_id" { type = string }
variable "subnet_ids" { type = list(string) }
variable "allowed_cidr_blocks" { type = list(string) }

variable "instance_type" { type = string }
variable "instance_count" {
  description = "Number of data nodes. With zone awareness on this must be a multiple of the AZ count, which the module derives from the number of subnets."
  type        = number

  validation {
    condition     = var.instance_count > 0
    error_message = "instance_count must be at least 1."
  }
}

variable "ebs_enabled" { type = bool }
variable "ebs_volume_size" { type = number }
variable "ebs_volume_type" { type = string }
variable "ebs_iops" { type = number }
variable "ebs_throughput" { type = number }

variable "kms_key_arn" { type = string }
variable "master_user_name" { type = string }
variable "master_user_password" {
  type      = string
  sensitive = true
}
variable "access_policies" { type = string }
variable "snapshot_hour" { type = number }
variable "tags" { type = map(string) }

variable "zone_awareness_enabled" { type = bool }
variable "dedicated_master_enabled" { type = bool }
variable "master_instance_type" {
  type    = string
  default = null # Makes it optional
}

variable "master_instance_count" {
  type    = number
  default = 0 # Defaults to 0 if not specified
}