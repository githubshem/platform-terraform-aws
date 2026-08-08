# =====================================================
# gaia Redis (ElastiCache replication group)
# Imported into Terraform to match the existing AWS resource.
# =====================================================

aws_region = "ap-southeast-1"

# 1. Identity
replication_group_id = "gaia"
description          = "Prod Redis cluster gaia"

# 2. Hardware & Versioning
engine_version = "7.1"
node_type      = "cache.m7g.large"
port           = 6379

# 3. Topology (matches live: 3 nodes, Multi-AZ with failover)
num_cache_clusters         = 3
automatic_failover_enabled = true
multi_az_enabled           = true

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
parameter_group_name = "test-eks-pg"

# 6. Networking (reuse existing subnet group; do not create)

# 7. Backup / Restore (fresh-managed, no restore)
snapshot_retention_limit  = 7
snapshot_window           = "11:00-12:00"
maintenance_window        = "sun:07:00-sun:08:00"
final_snapshot_identifier = "plat-prod-gaia-redis-final"

apply_immediately = true

tags = {}
