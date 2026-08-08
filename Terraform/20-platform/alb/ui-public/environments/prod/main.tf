# Network identifiers come from the VPC stack rather than hardcoded values.
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

module "ui_alb" {
  source = "../../modules"

  aws_region          = var.aws_region
  environment         = var.environment
  vpc_id              = data.terraform_remote_state.vpc.outputs.vpc_id
  public_subnets      = data.terraform_remote_state.vpc.outputs.public_subnet_ids
  ssl_certificate_arn = var.ssl_certificate_arn
  ui_services         = var.ui_services
  create_sg           = var.create_sg
  existing_sg_id      = data.terraform_remote_state.security_groups.outputs.alb_public_sg_id
  project_tags        = var.project_tags
}
