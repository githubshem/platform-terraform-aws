variable "environment" {}
variable "cluster_name" {}
variable "aws_region" {}
variable "container_insights" {}
variable "ec2_instance_type" {}
variable "min_size" {}
variable "max_size" {}
variable "vpc_id" {}
variable "private_subnets" { type = list(string) }
variable "service_security_group_ids" { type = list(string) }
variable "ecs_instance_profile_name" {}
variable "ecs_execution_role_arn" {}
variable "ecs_task_role_arn" {}
variable "target_capacity" {}
variable "microservices" { type = map(any) }
variable "ec2_key_name" {
  description = "The SSH key pair name to attach to ECS EC2 instances"
  type        = string
}

# Safely defaulted variables for clusters that don't need them
variable "ami_id" { default = "" }
variable "warm_pool_size" { default = 0 }
variable "dedicated_capacity_providers" { default = {} }
variable "project_tags" { default = {} }
variable "default_cp_weight" {
  description = "Default weight for the capacity provider"
  type        = number
  default     = 100
}

variable "cloudwatch_retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 30
}

variable "placement_strategy_type" {
  description = "The type of placement strategy (e.g., binpack, spread)"
  type        = string
  default     = "binpack"
}

variable "placement_strategy_field" {
  description = "The field to apply the placement strategy against (e.g., memory, cpu)"
  type        = string
  default     = "memory"
}

variable "app_prefix" {
  description = "Application family, e.g. zeus or hera. Forms the first segment of every resource name; changing it renames real infrastructure."
  type        = string
}

