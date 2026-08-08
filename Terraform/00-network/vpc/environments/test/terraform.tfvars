aws_region = "ap-southeast-1"

# --- VPC ---
create_vpc = true
vpc_name   = "plat-test-vpc"
vpc_cidr   = "10.9.0.0/16"

# One NAT gateway per AZ. Each private route table egresses through the NAT in
# its own AZ, so losing an AZ cannot take egress down for the others and no
# outbound packet pays a cross-AZ transfer charge.
nat_subnets = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]

# --- Tier 1: public (load balancers, NAT gateways) ---
public_subnets = [
  { name = "plat-test-public-1a", az = "ap-southeast-1a", cidr = "10.9.0.0/22" },
  { name = "plat-test-public-1b", az = "ap-southeast-1b", cidr = "10.9.4.0/22" },
  { name = "plat-test-public-1c", az = "ap-southeast-1c", cidr = "10.9.8.0/22" },
]

# --- Tier 2: private application (ECS container instances) ---
private_subnets = [
  { name = "plat-test-app-1a", az = "ap-southeast-1a", cidr = "10.9.16.0/20" },
  { name = "plat-test-app-1b", az = "ap-southeast-1b", cidr = "10.9.32.0/20" },
  { name = "plat-test-app-1c", az = "ap-southeast-1c", cidr = "10.9.48.0/20" },
]

# --- Tier 3: EKS (worker nodes and pod ENIs) ---
# Sized /19 (8190 usable) per AZ because the VPC CNI assigns a real VPC IP to
# every pod, not just every node. Undersizing here shows up as unschedulable
# pods long before CPU or memory run out.
eks_subnets = [
  { name = "plat-test-eks-1a", az = "ap-southeast-1a", cidr = "10.9.64.0/19" },
  { name = "plat-test-eks-1b", az = "ap-southeast-1b", cidr = "10.9.96.0/19" },
  { name = "plat-test-eks-1c", az = "ap-southeast-1c", cidr = "10.9.128.0/19" },
]

# --- Tier 4: data (RDS, ElastiCache, Amazon MQ, OpenSearch) ---
data_subnets = [
  { name = "plat-test-data-1a", az = "ap-southeast-1a", cidr = "10.9.160.0/22" },
  { name = "plat-test-data-1b", az = "ap-southeast-1b", cidr = "10.9.164.0/22" },
  { name = "plat-test-data-1c", az = "ap-southeast-1c", cidr = "10.9.168.0/22" },
]

# 10.9.176.0 and above is unallocated, reserved for future tiers.

enable_flow_logs        = true
flow_log_retention_days = 90

project_tags = {
  Project     = "ExampleCorp"
  Environment = "test"
  Team        = "engineering"
  ManagedBy   = "terraform"
}
