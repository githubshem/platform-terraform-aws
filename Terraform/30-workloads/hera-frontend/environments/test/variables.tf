variable "aws_region" { type = string }
variable "environment" { type = string }
variable "cluster_name" { type = string }
variable "ec2_instance_type" { type = string }
variable "ami_id" { type = string }
variable "min_size" { type = number }
variable "max_size" { type = number }
variable "warm_pool_size" { type = number }
variable "target_capacity" { type = number }
variable "ecs_instance_profile_name" { type = string }
variable "ecs_execution_role_arn" { type = string }
variable "ecs_task_role_arn" { type = string }
variable "cloudwatch_retention_days" { type = number }
variable "placement_strategy_type" { type = string }
variable "placement_strategy_field" { type = string }
variable "project_tags" { type = map(string) }

variable "fe_microservices" {
  type = map(object({
    cpu                = number
    memory             = number
    memory_reservation = number
    port               = number
    image              = string
    target_group_arn   = string
    min_count          = number
    max_count          = number
    cpu_target         = number
    memory_target      = number
  }))
}
variable "container_insights" {
  type    = string
  default = "disabled"
}
