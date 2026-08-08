output "replication_group_id" {
  description = "ID of the Redis replication group"
  value       = aws_elasticache_replication_group.this.id
}

output "primary_endpoint_address" {
  description = "Primary (write) endpoint of the Redis cluster"
  value       = aws_elasticache_replication_group.this.primary_endpoint_address
}

output "reader_endpoint_address" {
  description = "Reader endpoint of the Redis cluster"
  value       = aws_elasticache_replication_group.this.reader_endpoint_address
}

output "port" {
  description = "Port the Redis cluster listens on"
  value       = aws_elasticache_replication_group.this.port
}

output "member_clusters" {
  description = "Identifiers of all nodes in the replication group"
  value       = aws_elasticache_replication_group.this.member_clusters
}

output "subnet_group_name" {
  description = "Subnet group used by the Redis cluster"
  value       = local.subnet_group_name
}
