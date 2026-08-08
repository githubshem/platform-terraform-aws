# When create_db_subnet_group = true (default) Terraform creates and manages the
# subnet group. When false, it looks up an EXISTING subnet group by name instead.
resource "aws_db_subnet_group" "this" {
  count       = var.create_db_subnet_group ? 1 : 0
  name        = var.db_subnet_group_name
  subnet_ids  = var.private_subnet_ids
  description = "Subnet group for ${var.cluster_identifier}"
}

data "aws_db_subnet_group" "existing" {
  count = var.create_db_subnet_group ? 0 : 1
  name  = var.db_subnet_group_name
}


locals {
  db_subnet_group_name = var.create_db_subnet_group ? aws_db_subnet_group.this[0].name : data.aws_db_subnet_group.existing[0].name
}

# 1. The RDS Cluster
resource "aws_rds_cluster" "this" {
  cluster_identifier = var.cluster_identifier
  engine             = "aurora-mysql"
  engine_version     = var.rds_engine_version
  master_username    = var.rds_username
  master_password    = var.rds_password # Injected safely from Secrets Manager

  # Snapshot & Backups
  snapshot_identifier     = var.snapshot_identifier
  backup_retention_period = var.backup_retention_days

  # Network & Security
  db_subnet_group_name   = local.db_subnet_group_name
  vpc_security_group_ids = var.rds_vpc_security_group_ids
  storage_encrypted      = true # Defaults to AWS Managed KMS Key

  # Advanced Configs
  db_cluster_parameter_group_name     = var.cluster_parameter_group_name
  iam_database_authentication_enabled = var.iam_database_authentication_enabled
  deletion_protection                 = var.deletion_protection
  skip_final_snapshot                 = var.skip_final_snapshot
  apply_immediately                   = false

  lifecycle {
    ignore_changes = [
      snapshot_identifier,
      master_password,
      availability_zones
    ]
  }
}

# 2. The Database Instances (Writer + Optional Readers)
resource "aws_rds_cluster_instance" "this" {
  count      = length(var.instance_names)
  identifier = var.instance_names[count.index]

  cluster_identifier = aws_rds_cluster.this.id
  instance_class     = var.rds_instance_class
  engine             = aws_rds_cluster.this.engine
  engine_version     = aws_rds_cluster.this.engine_version

  db_parameter_group_name               = var.db_parameter_group_name
  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_enabled ? var.performance_insights_retention_period : null
  publicly_accessible                   = false
  apply_immediately                     = false

  # Instance 0 is Tier 1 (Writer). Any additional instances are Tier 2 (Readers).
  promotion_tier = count.index == 0 ? 1 : 2
}

# 3. OPTIONAL: Reader Auto-Scaling (Only active if autoscaling_enabled = true)
resource "aws_appautoscaling_target" "replica_target" {
  count              = var.autoscaling_enabled ? 1 : 0
  max_capacity       = var.autoscaling_max
  min_capacity       = var.autoscaling_min
  resource_id        = "cluster:${aws_rds_cluster.this.cluster_identifier}"
  scalable_dimension = "rds:cluster:ReadReplicaCount"
  service_namespace  = "rds"
}

resource "aws_appautoscaling_policy" "replica_policy" {
  count              = var.autoscaling_enabled ? 1 : 0
  name               = "cpu-auto-scaling-${var.cluster_identifier}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.replica_target[0].resource_id
  scalable_dimension = aws_appautoscaling_target.replica_target[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.replica_target[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "RDSReaderAverageCPUUtilization"
    }
    target_value       = var.autoscaling_target_cpu
    scale_in_cooldown  = 180
    scale_out_cooldown = 180
  }
}