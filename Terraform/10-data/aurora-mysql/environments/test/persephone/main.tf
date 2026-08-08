# Network identifiers come from the VPC and security-group stacks rather than
# from hardcoded values in terraform.tfvars.
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

# Fetch the master password from AWS Secrets Manager
data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = var.secret_name
}

module "aurora_db" {
  source = "../../../modules/aurora-mysql"

  cluster_identifier = var.cluster_identifier
  instance_names     = var.instance_names
  rds_username       = var.rds_username
  rds_password       = data.aws_secretsmanager_secret_version.db_password.secret_string

  # This stack owns its subnet group, built from the VPC stack's data tier.
  # It previously pointed at the account default subnet group.
  create_db_subnet_group = true
  db_subnet_group_name   = "${var.cluster_identifier}-subnets"
  private_subnet_ids     = data.terraform_remote_state.vpc.outputs.data_subnet_ids

  rds_vpc_security_group_ids = [data.terraform_remote_state.security_groups.outputs.ecs_be_sg_id]

  rds_engine_version = var.rds_engine_version
  rds_instance_class = var.rds_instance_class

  backup_retention_days               = var.backup_retention_days
  deletion_protection                 = var.deletion_protection
  skip_final_snapshot                 = var.skip_final_snapshot
  cluster_parameter_group_name        = var.cluster_parameter_group_name
  db_parameter_group_name             = var.db_parameter_group_name
  iam_database_authentication_enabled = var.iam_database_authentication_enabled
  performance_insights_enabled        = var.performance_insights_enabled

  autoscaling_enabled    = var.autoscaling_enabled
  autoscaling_min        = var.autoscaling_min
  autoscaling_max        = var.autoscaling_max
  autoscaling_target_cpu = var.autoscaling_target_cpu
}
