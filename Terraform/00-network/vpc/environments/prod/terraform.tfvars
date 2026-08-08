aws_region = "ap-southeast-1"

# --- VPC ---
create_vpc = true
vpc_name   = "plat-prod-vpc"
vpc_cidr   = "10.10.0.0/16"

# One NAT gateway per AZ. Each private route table egresses through the NAT in
# its own AZ, so losing an AZ cannot take egress down for the others and no
# outbound packet pays a cross-AZ transfer charge.
nat_subnets = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]

# --- Tier 1: public (load balancers, NAT gateways) ---
public_subnets = [
  { name = "plat-prod-public-1a", az = "ap-southeast-1a", cidr = "10.10.0.0/22" },
  { name = "plat-prod-public-1b", az = "ap-southeast-1b", cidr = "10.10.4.0/22" },
  { name = "plat-prod-public-1c", az = "ap-southeast-1c", cidr = "10.10.8.0/22" },
]

# --- Tier 2: private application (ECS container instances) ---
private_subnets = [
  { name = "plat-prod-app-1a", az = "ap-southeast-1a", cidr = "10.10.16.0/20" },
  { name = "plat-prod-app-1b", az = "ap-southeast-1b", cidr = "10.10.32.0/20" },
  { name = "plat-prod-app-1c", az = "ap-southeast-1c", cidr = "10.10.48.0/20" },
]

# --- Tier 3: EKS (worker nodes and pod ENIs) ---
# Sized /19 (8190 usable) per AZ because the VPC CNI assigns a real VPC IP to
# every pod, not just every node. Undersizing here shows up as unschedulable
# pods long before CPU or memory run out.
eks_subnets = [
  { name = "plat-prod-eks-1a", az = "ap-southeast-1a", cidr = "10.10.64.0/19" },
  { name = "plat-prod-eks-1b", az = "ap-southeast-1b", cidr = "10.10.96.0/19" },
  { name = "plat-prod-eks-1c", az = "ap-southeast-1c", cidr = "10.10.128.0/19" },
]

# --- Tier 4: data (RDS, ElastiCache, Amazon MQ, OpenSearch) ---
data_subnets = [
  { name = "plat-prod-data-1a", az = "ap-southeast-1a", cidr = "10.10.160.0/22" },
  { name = "plat-prod-data-1b", az = "ap-southeast-1b", cidr = "10.10.164.0/22" },
  { name = "plat-prod-data-1c", az = "ap-southeast-1c", cidr = "10.10.168.0/22" },
]

# 10.10.176.0 and above is unallocated, reserved for future tiers.

enable_flow_logs        = true
flow_log_retention_days = 90

project_tags = {
  Project     = "ExampleCorp"
  Environment = "prod"
  Team        = "engineering"
  ManagedBy   = "terraform"
}
