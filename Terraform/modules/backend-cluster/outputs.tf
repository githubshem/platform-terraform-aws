output "cluster_id" {
  description = "The ID of the ECS cluster"
  value       = aws_ecs_cluster.this.id
}

output "cluster_name" {
  description = "The Name of the ECS cluster"
  value       = aws_ecs_cluster.this.name
}

output "ec2_capacity_provider" {
  description = "The name of the primary EC2 capacity provider"
  value       = aws_ecs_capacity_provider.primary_cp.name
}