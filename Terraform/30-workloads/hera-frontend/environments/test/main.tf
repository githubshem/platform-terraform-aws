# Network identifiers come from the VPC and security-group stacks rather than
# hardcoded values, so a subnet or SG replacement propagates on the next apply.
data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = "plat-test-terraform-state"
    key    = "test/vpc/terraform.tfstate"
    region = "ap-southeast-1"
  }
}

data "terraform_remote_state" "security_groups" {
  backend = "s3"

  config = {
    bucket = "plat-test-terraform-state"
    key    = "test/security-groups/terraform.tfstate"
    region = "ap-southeast-1"
  }
}

# 1. Create the Compute Cluster (ASG & EC2)
module "ecs_cluster" {
  source                    = "../../../../modules/frontend-cluster"
  environment               = var.environment
  cluster_name              = var.cluster_name
  vpc_id                    = data.terraform_remote_state.vpc.outputs.vpc_id
  private_subnets           = data.terraform_remote_state.vpc.outputs.private_app_subnet_ids
  ec2_instance_type         = var.ec2_instance_type
  ami_id                    = var.ami_id
  min_size                  = var.min_size
  max_size                  = var.max_size
  warm_pool_size            = var.warm_pool_size
  target_capacity           = var.target_capacity
  ecs_instance_profile_name = var.ecs_instance_profile_name
  project_tags              = var.project_tags
}

# 2. Deploy the Microservices (Task Defs & Services)
module "ecs_service" {
  source                    = "../../../../modules/frontend-service"
  environment               = var.environment
  vpc_id                    = data.terraform_remote_state.vpc.outputs.vpc_id
  private_subnets           = data.terraform_remote_state.vpc.outputs.private_app_subnet_ids
  public_alb_sg_id          = data.terraform_remote_state.security_groups.outputs.alb_public_sg_id
  cluster_name              = var.cluster_name
  capacity_provider_name    = module.ecs_cluster.capacity_provider_name
  ecs_execution_role_arn    = var.ecs_execution_role_arn
  ecs_task_role_arn         = var.ecs_task_role_arn
  cloudwatch_retention_days = var.cloudwatch_retention_days
  placement_strategy_type   = var.placement_strategy_type
  placement_strategy_field  = var.placement_strategy_field
  fe_microservices          = var.fe_microservices
  project_tags              = var.project_tags
}