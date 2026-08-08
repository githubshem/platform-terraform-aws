# ---------------------------------------------------------------------------
# Outputs
#
# These are the contract every downstream stack reads through
# terraform_remote_state. Renaming one is a breaking change for RDS, Redis,
# ECS, EKS, ALB, RabbitMQ, and OpenSearch, so treat them as a public API.
#
# Subnet ID lists are sorted by availability zone so ordering stays stable
# across plans and a reordered map cannot produce a spurious diff downstream.
# ---------------------------------------------------------------------------

output "vpc_id" {
  description = "ID of the VPC being used (created or existing)."
  value       = local.vpc_id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC."
  value       = var.create_vpc ? aws_vpc.main[0].cidr_block : data.aws_vpc.existing[0].cidr_block
}

output "igw_id" {
  description = "ID of the internet gateway being used (created or existing)."
  value       = local.igw_id
}

output "azs" {
  description = "Availability zones carrying private capacity."
  value       = sort(local.private_azs)
}

output "public_subnet_ids" {
  description = "Public tier subnet IDs, sorted by AZ."
  value       = [for az in sort(keys(aws_subnet.public)) : aws_subnet.public[az].id]
}

output "private_app_subnet_ids" {
  description = "Private application tier subnet IDs (ECS), sorted by AZ."
  value       = [for az in sort(keys(aws_subnet.private)) : aws_subnet.private[az].id]
}

output "eks_subnet_ids" {
  description = "EKS tier subnet IDs (nodes and pod ENIs), sorted by AZ."
  value       = [for az in sort(keys(aws_subnet.eks)) : aws_subnet.eks[az].id]
}

output "data_subnet_ids" {
  description = "Data tier subnet IDs (RDS, ElastiCache, Amazon MQ, OpenSearch), sorted by AZ."
  value       = [for az in sort(keys(aws_subnet.data)) : aws_subnet.data[az].id]
}

output "public_subnet_ids_by_az" {
  description = "Public tier subnet IDs keyed by availability zone."
  value       = { for az, s in aws_subnet.public : az => s.id }
}

output "private_app_subnet_ids_by_az" {
  description = "Private application tier subnet IDs keyed by availability zone."
  value       = { for az, s in aws_subnet.private : az => s.id }
}

output "eks_subnet_ids_by_az" {
  description = "EKS tier subnet IDs keyed by availability zone."
  value       = { for az, s in aws_subnet.eks : az => s.id }
}

output "data_subnet_ids_by_az" {
  description = "Data tier subnet IDs keyed by availability zone."
  value       = { for az, s in aws_subnet.data : az => s.id }
}

output "nat_gateway_ids" {
  description = "NAT gateway IDs keyed by availability zone."
  value       = { for az, n in aws_nat_gateway.nat : az => n.id }
}

output "nat_public_ips" {
  description = "Elastic IPs of the NAT gateways. Useful for third-party allowlists."
  value       = { for az, e in aws_eip.nat : az => e.public_ip }
}
