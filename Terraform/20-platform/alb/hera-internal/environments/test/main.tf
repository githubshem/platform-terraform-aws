# Network identifiers come from the VPC stack rather than hardcoded values.
data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = "plat-test-terraform-state"
    key    = "test/vpc/terraform.tfstate"
    region = "ap-southeast-1"
  }
}

data "aws_vpc" "selected" {
  id = data.terraform_remote_state.vpc.outputs.vpc_id
}

module "internal_alb" {
  source                     = "../../modules" # Flatted structure as requested
  environment                = var.environment
  vpc_id                     = data.terraform_remote_state.vpc.outputs.vpc_id
  vpc_cidr                   = data.aws_vpc.selected.cidr_block
  private_subnets            = data.terraform_remote_state.vpc.outputs.private_app_subnet_ids
  alb_services               = var.alb_services
  enable_deletion_protection = true
  idle_timeout               = 300
}

output "alb_url" {
  value = module.internal_alb.alb_dns_name
}

output "target_groups_to_copy_to_ecs" {
  value = module.internal_alb.target_group_arns
}