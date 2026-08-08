# Network identifiers come from the VPC stack rather than hardcoded values.
data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = "plat-prod-terraform-state"
    key    = "prod/vpc/terraform.tfstate"
    region = "ap-southeast-1"
  }
}

# Call the module from the parent directory
module "zeus_internal_alb" {
  source = "../../modules/internal-alb"

  environment     = var.environment
  vpc_id          = data.terraform_remote_state.vpc.outputs.vpc_id
  private_subnets = data.terraform_remote_state.vpc.outputs.private_app_subnet_ids
  vpc_cidr_block  = data.terraform_remote_state.vpc.outputs.vpc_cidr
  alb_name        = var.alb_name
  alb_services    = var.alb_services
  project_tags    = var.project_tags
}