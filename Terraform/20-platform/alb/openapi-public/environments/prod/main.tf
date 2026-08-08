# Network identifiers come from the VPC stack rather than hardcoded values.
data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = "plat-prod-terraform-state"
    key    = "prod/vpc/terraform.tfstate"
    region = "ap-southeast-1"
  }
}

module "openapi_dns_alb" {
  source = "../../modules/openapi-alb"

  environment                   = var.environment
  vpc_id                        = data.terraform_remote_state.vpc.outputs.vpc_id
  private_subnets               = data.terraform_remote_state.vpc.outputs.private_app_subnet_ids
  vpc_cidr_block                = data.terraform_remote_state.vpc.outputs.vpc_cidr
  alb_name                      = var.alb_name
  alb_services                  = var.alb_services
  project_tags                  = var.project_tags
  create_public_alb_rules       = var.create_public_alb_rules
  public_alb_https_listener_arn = var.public_alb_https_listener_arn
  public_tg_name_prefix         = var.public_tg_name_prefix
  public_domain                 = var.public_domain
  public_rule_priority_start    = var.public_rule_priority_start
}

output "alb_dns_name" {
  value = module.openapi_dns_alb.alb_dns_name
}

output "alb_security_group_id" {
  value = module.openapi_dns_alb.alb_security_group_id
}

output "target_group_arns" {
  value = module.openapi_dns_alb.target_group_arns
}

output "public_target_group_arns" {
  value = module.openapi_dns_alb.public_target_group_arns
}

output "public_rule_hosts" {
  value = module.openapi_dns_alb.public_rule_hosts
}
