# =====================================================
# hera Redis (ElastiCache replication group)
# Imported into Terraform to match the existing AWS resource.
# =====================================================

aws_region = "ap-southeast-1"

# 1. Identity
replication_group_id = "hera"
description          = "Prod Redis cluster hera"

# 2. Hardware & Versioning
engine_version = "6.2"
node_type      = "cache.r7g.large"
port           = 6583

# 3. Topology (matches live: 2 nodes, no Multi-AZ / failover)
num_cache_clusters         = 2
automatic_failover_enabled = false
multi_az_enabled           = false

# 4. Encryption
#
# REPLACEMENT REQUIRED. Both flags are immutable on a live replication group, so
# applying this destroys and recreates the cluster. Two consequences:
#
#   1. Cache contents are lost. final_snapshot_identifier below takes a snapshot
#      first; set snapshot_name to restore from it if the data matters.
#   2. transit_encryption_enabled makes the endpoint TLS-only. Every client must
#      be able to speak TLS BEFORE this is applied, or it connects to a healthy
#      cluster and fails. Roll this through test first and confirm clients there.
#
# Do not apply this in the same change as anything else.
at_rest_encryption_enabled = true
transit_encryption_enabled = true

# 5. Parameter group
parameter_group_name = "default.redis6.x"

# 6. Networking (reuse existing subnet group; do not create)

# 7. Backup / Restore (fresh-managed, no restore)
snapshot_retention_limit  = 7
snapshot_window           = "17:14-18:14"
maintenance_window        = "sat:13:00-sat:14:00"
final_snapshot_identifier = "plat-prod-hera-redis-final"

apply_immediately = true

tags = {
  Environment = "prod"
}
