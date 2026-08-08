variable "environment" {}
variable "cluster_name" {}
variable "container_insights" {}
variable "ec2_instance_type" {}
variable "private_subnets" { type = list(string) }
variable "service_security_group_ids" { type = list(string) }
variable "min_size" { type = number }
variable "max_size" { type = number }
variable "ecs_instance_profile_name" {}
variable "target_capacity" {}
variable "warm_pool_size" {
  description = "The number of EC2 instances to keep ready in the Warm Pool"
  type        = number
  default     = 0
}
variable "tags" {
  description = "Common tags to apply to all resources for cost tracking"
  type        = map(string)
  default     = {}
}
variable "ec2_key_name" {
  description = "The name of the SSH Key Pair (PEM file) in AWS"
  type        = string
}

variable "dedicated_capacity_providers" {
  description = "A map to create dedicated ASGs and Capacity Providers for specific services"
  type = map(object({
    instance_type = string
    min_size      = number
    max_size      = number
  }))
  default = {} # If omitted in tfvars, nothing extra is created!
}
variable "ami_id" {
  description = "The AMI ID for the ECS instances"
  type        = string
}

variable "security_group_ids" {
  description = "List of Security Group IDs for the ECS nodes"
  type        = list(string)
}

variable "default_cp_weight" { default = 1 }

variable "app_prefix" {
  description = <<-EOT
    Application family this cluster belongs to, e.g. zeus or hera. It is the
    literal first segment of every resource name this module creates. This module
    used to exist as two byte-identical copies differing only in that literal,
    so changing the value renames real infrastructure -- it is not cosmetic.
  EOT
  type        = string
}

