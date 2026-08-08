# Network identifiers come from the VPC and security-group stacks rather than
# hardcoded values, so a subnet or SG replacement propagates on the next apply.
data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = "plat-prod-terraform-state"
    key    = "prod/vpc/terraform.tfstate"
    region = "ap-southeast-1"
  }
}

data "terraform_remote_state" "security_groups" {
  backend = "s3"

  config = {
    bucket = "plat-prod-terraform-state"
    key    = "prod/security-groups/terraform.tfstate"
    region = "ap-southeast-1"
  }
}

module "cluster_setup" {
  source = "../../../../../../modules/backend-cluster-setup"

  app_prefix                   = "hera"
  environment                  = var.environment
  cluster_name                 = var.cluster_name
  aws_region                   = var.aws_region
  container_insights           = var.container_insights
  ec2_instance_type            = var.ec2_instance_type
  min_size                     = var.min_size
  max_size                     = var.max_size
  vpc_id                       = data.terraform_remote_state.vpc.outputs.vpc_id
  private_subnets              = data.terraform_remote_state.vpc.outputs.private_app_subnet_ids
  service_security_group_ids   = [data.terraform_remote_state.security_groups.outputs.ecs_be_sg_id]
  ecs_instance_profile_name    = var.ecs_instance_profile_name
  ecs_execution_role_arn       = var.ecs_execution_role_arn
  ecs_task_role_arn            = var.ecs_task_role_arn
  target_capacity              = var.target_capacity
  microservices                = var.microservices
  ami_id                       = var.ami_id
  warm_pool_size               = var.warm_pool_size
  dedicated_capacity_providers = var.dedicated_capacity_providers
  project_tags                 = var.project_tags
  default_cp_weight            = var.default_cp_weight
  cloudwatch_retention_days    = var.cloudwatch_retention_days
  placement_strategy_type      = var.placement_strategy_type
  placement_strategy_field     = var.placement_strategy_field
  ec2_key_name                 = var.ec2_key_name
}

# --- REQUIRE THE VARIABLES IN THIS BRIDGE FILE ---
variable "environment" { type = string }
variable "cluster_name" { type = string }
variable "aws_region" { type = string }
variable "container_insights" { type = string }
variable "ec2_instance_type" { type = string }
variable "min_size" { type = number }
variable "max_size" { type = number }
variable "ecs_instance_profile_name" { type = string }
variable "ecs_execution_role_arn" { type = string }
variable "ecs_task_role_arn" { type = string }
variable "target_capacity" { type = number }
variable "microservices" { type = any }
variable "ami_id" {
  type    = string
  default = ""
}
variable "warm_pool_size" {
  type    = number
  default = 0
}
variable "dedicated_capacity_providers" {
  type    = map(any)
  default = {}
}
variable "project_tags" {
  type    = map(any)
  default = {}
}
variable "default_cp_weight" {
  type    = number
  default = 1
}
variable "cloudwatch_retention_days" {
  type    = number
  default = 30
}
variable "placement_strategy_type" {
  type    = string
  default = "spread"
}
variable "placement_strategy_field" {
  type    = string
  default = "attribute:ecs.availability-zone"
}
variable "ec2_key_name" { type = string }