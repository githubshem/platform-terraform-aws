variable "environment" {}
variable "vpc_id" {}
variable "private_subnets" {}
variable "public_alb_sg_id" {}
variable "cluster_name" {}
variable "capacity_provider_name" {}
variable "ecs_execution_role_arn" {}
variable "ecs_task_role_arn" {}
variable "cloudwatch_retention_days" {}
variable "placement_strategy_type" {}
variable "placement_strategy_field" {}
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
variable "project_tags" {}

variable "existing_ecs_tasks_sg_id" {
  description = "ID of an existing SG. If provided, the module will skip creating a new SG."
  type        = string
  default     = null
}