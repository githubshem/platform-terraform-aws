# ---------------------------------------------------------------------------
# Published outputs
#
# Every downstream stack (RDS, Redis, ECS, EKS, ALB, RabbitMQ, OpenSearch)
# reads these through a terraform_remote_state data source pointed at this
# workspace's state key. Renaming any of them is a breaking change.
# ---------------------------------------------------------------------------

output "vpc_id" {
  description = "ID of the VPC."
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC."
  value       = module.vpc.vpc_cidr
}

output "azs" {
  description = "Availability zones carrying private capacity."
  value       = module.vpc.azs
}

output "public_subnet_ids" {
  description = "Public tier subnet IDs, sorted by AZ."
  value       = module.vpc.public_subnet_ids
}

output "private_app_subnet_ids" {
  description = "Private application tier subnet IDs (ECS), sorted by AZ."
  value       = module.vpc.private_app_subnet_ids
}

output "eks_subnet_ids" {
  description = "EKS tier subnet IDs, sorted by AZ."
  value       = module.vpc.eks_subnet_ids
}

output "data_subnet_ids" {
  description = "Data tier subnet IDs, sorted by AZ."
  value       = module.vpc.data_subnet_ids
}

output "nat_public_ips" {
  description = "Elastic IPs of the NAT gateways, keyed by AZ."
  value       = module.vpc.nat_public_ips
}
