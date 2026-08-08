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

data "aws_secretsmanager_secret_version" "admin" {
  secret_id = var.admin_secret_name
}

locals {
  admin_creds = jsondecode(data.aws_secretsmanager_secret_version.admin.secret_string)
}

module "rabbitmq_cluster" {
  source = "../../modules/rabbitmq-cluster"

  environment        = var.environment
  broker_name        = var.broker_name
  engine_version     = var.engine_version
  host_instance_type = var.host_instance_type
  deployment_mode    = var.deployment_mode

  auto_minor_version_upgrade = var.auto_minor_version_upgrade
  enable_general_logs        = var.enable_general_logs
  manage_default_tags        = var.manage_default_tags

  kms_key_id             = var.kms_key_id
  configuration_id       = var.configuration_id
  configuration_revision = var.configuration_revision

  subnet_ids      = data.terraform_remote_state.vpc.outputs.data_subnet_ids
  security_groups = [data.terraform_remote_state.security_groups.outputs.ecs_be_sg_id]
  admin_username  = local.admin_creds[var.admin_username_key]
  admin_password  = local.admin_creds[var.admin_password_key]

  maintenance_day  = var.maintenance_day
  maintenance_time = var.maintenance_time

  project_tags = var.project_tags
}
