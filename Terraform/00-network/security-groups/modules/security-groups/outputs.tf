output "alb_public_sg_id" {
  value       = aws_security_group.alb_public.id
  description = "The ID of the Public Application Load Balancer Security Group"
}

output "alb_private_sg_id" {
  value       = aws_security_group.alb_private.id
  description = "The ID of the Private Application Load Balancer Security Group"
}

output "ecs_be_sg_id" {
  value       = aws_security_group.ecs_be.id
  description = "The ID of the Unified Backend and Data Layer Security Group"
}
output "eks_nodes_sg_id" {
  value       = aws_security_group.eks_nodes.id
  description = "The ID of the EKS worker node and pod ENI Security Group"
}
