# ---------------------------------------------------------------------------
# Published outputs
#
# ALB, ECS, EKS, RDS, Redis, RabbitMQ, and OpenSearch stacks read these through
# terraform_remote_state instead of carrying hardcoded sg-* values. Renaming any
# of them is a breaking change.
# ---------------------------------------------------------------------------

output "alb_public_sg_id" {
  description = "Public (internet-facing) ALB security group."
  value       = module.security_groups.alb_public_sg_id
}

output "alb_private_sg_id" {
  description = "Internal ALB security group."
  value       = module.security_groups.alb_private_sg_id
}

output "ecs_be_sg_id" {
  description = "Shared backend and data layer security group (ECS, RDS, Redis, OpenSearch, RabbitMQ)."
  value       = module.security_groups.ecs_be_sg_id
}

output "eks_nodes_sg_id" {
  description = "EKS worker node and pod ENI security group."
  value       = module.security_groups.eks_nodes_sg_id
}
