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

module "redis" {
  source = "../../../modules/elasticache-redis"

  replication_group_id = var.replication_group_id
  description          = var.description

  engine_version = var.engine_version
  node_type      = var.node_type
  port           = var.port

  num_cache_clusters         = var.num_cache_clusters
  automatic_failover_enabled = var.automatic_failover_enabled
  multi_az_enabled           = var.multi_az_enabled

  at_rest_encryption_enabled = var.at_rest_encryption_enabled
  transit_encryption_enabled = var.transit_encryption_enabled

  # Accepted exception: current Redis clusters intentionally use AWS default parameter groups. Revisit when custom Redis parameter groups are defined.
  # tflint-ignore: aws_elasticache_replication_group_default_parameter_group
  parameter_group_name = var.parameter_group_name

  private_subnet_ids        = data.terraform_remote_state.vpc.outputs.data_subnet_ids
  subnet_group_name         = "${var.replication_group_id}-subnets"
  create_subnet_group       = true
  security_group_ids        = [data.terraform_remote_state.security_groups.outputs.ecs_be_sg_id]
  snapshot_retention_limit  = var.snapshot_retention_limit
  snapshot_window           = var.snapshot_window
  maintenance_window        = var.maintenance_window
  final_snapshot_identifier = var.final_snapshot_identifier

  apply_immediately = var.apply_immediately
  tags              = var.tags
}