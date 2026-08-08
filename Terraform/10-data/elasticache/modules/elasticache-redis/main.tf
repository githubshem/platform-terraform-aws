# When create_subnet_group = true (default) Terraform creates and manages the
# subnet group. When false, it looks up an EXISTING subnet group by name instead.
resource "aws_elasticache_subnet_group" "this" {
  count       = var.create_subnet_group ? 1 : 0
  name        = var.subnet_group_name
  subnet_ids  = var.private_subnet_ids
  description = "Subnet group for ${var.replication_group_id}"
}

data "aws_elasticache_subnet_group" "existing" {
  count = var.create_subnet_group ? 0 : 1
  name  = var.subnet_group_name
}

locals {
  subnet_group_name         = var.create_subnet_group ? aws_elasticache_subnet_group.this[0].name : data.aws_elasticache_subnet_group.existing[0].name
  snapshot_name             = var.snapshot_name != "" ? var.snapshot_name : null
  final_snapshot_identifier = var.final_snapshot_identifier != "" ? var.final_snapshot_identifier : null
}

# Redis Replication Group (non-clustered, single shard, Multi-AZ + failover).
# Restores from var.snapshot_name when provided.
resource "aws_elasticache_replication_group" "this" {
  replication_group_id = var.replication_group_id
  description          = var.description

  engine         = "redis"
  engine_version = var.engine_version
  node_type      = var.node_type
  port           = var.port

  num_cache_clusters         = var.num_cache_clusters
  automatic_failover_enabled = var.automatic_failover_enabled
  multi_az_enabled           = var.multi_az_enabled

  at_rest_encryption_enabled = var.at_rest_encryption_enabled
  transit_encryption_enabled = var.transit_encryption_enabled

  subnet_group_name    = local.subnet_group_name
  security_group_ids   = var.security_group_ids
  parameter_group_name = var.parameter_group_name

  # Restore source (null when creating a fresh cluster)
  snapshot_name = local.snapshot_name

  snapshot_retention_limit  = var.snapshot_retention_limit
  snapshot_window           = var.snapshot_window
  maintenance_window        = var.maintenance_window
  final_snapshot_identifier = local.final_snapshot_identifier

  apply_immediately = var.apply_immediately

  tags = var.tags

  lifecycle {
    ignore_changes = [
      snapshot_name,
      num_cache_clusters
    ]
  }
}
