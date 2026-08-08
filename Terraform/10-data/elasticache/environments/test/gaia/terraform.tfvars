# =====================================================
# plat-test-gaia-redis Redis (ElastiCache replication group)
# =====================================================

aws_region = "ap-southeast-1"

# 1. Identity
replication_group_id = "plat-test-gaia-redis"
description          = "Test Redis cluster plat-test-gaia-redis"

# 2. Hardware & Versioning
engine_version = "7.1"
node_type      = "cache.m7g.large"
port           = 6379

# 3. Topology (1 primary + 1 replica, Multi-AZ with failover)
num_cache_clusters         = 2
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

# 5. Parameter group (must match the engine version family)
parameter_group_name = "default.redis7"

# 6. Networking
# Reuses the shared subnet group created by selene.
# private_subnet_ids not used when create_subnet_group = false (lookup by name).

# 7. Backup / Restore
# Restore this cluster from the existing snapshot/backup of the same name.
snapshot_retention_limit  = 7
snapshot_window           = "03:00-05:00"
maintenance_window        = "sun:05:00-sun:07:00"
final_snapshot_identifier = "plat-test-gaia-redis-final"

apply_immediately = true

tags = {
  Name        = "plat-test-gaia-redis"
  Environment = "test"
  ManagedBy   = "terraform"
}