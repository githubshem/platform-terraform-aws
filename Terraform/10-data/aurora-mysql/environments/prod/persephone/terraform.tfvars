# 1. Identity & Sourcing
cluster_identifier = "persephone-prod-cluster"
instance_names     = ["persephone-prod-instance", "persephone-prod-reader"]
# A single instance means no failover target: if the writer dies Aurora has to
# provision a replacement, which is a ten-minute-plus outage instead of the ~30s
# failover Aurora exists to give you. The reader sits in another AZ at
# promotion_tier 2 and is the failover target.

# 2. Hardware & Versioning
rds_engine_version = "8.0.mysql_aurora.3.10.3"
rds_instance_class = "db.r7g.large"

# 3. Security & Credentials
rds_username                        = "persephone_admin"
secret_name                         = "prod/rds/persephone-rds-db-pwd" # Your AWS Secrets Manager Secret Name
deletion_protection                 = true
skip_final_snapshot                 = true # Set to false where a final snapshot on destroy is required.
iam_database_authentication_enabled = false

# 4. Networking

# 5. Backup & Parameters
backup_retention_days                 = 7
cluster_parameter_group_name          = "default.aurora-mysql8.0"
db_parameter_group_name               = "default.aurora-mysql8.0"
performance_insights_enabled          = true
performance_insights_retention_period = 7

# 6. Future Proofing (Reader Auto-Scaling)
autoscaling_enabled    = true
autoscaling_min        = 1
autoscaling_max        = 3
autoscaling_target_cpu = 70