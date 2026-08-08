# ---------------------------------------------------------------------------
# Subnets
#
# Every tier is keyed by availability zone, so a tier holds at most one subnet
# per AZ. That keeps route table association and NAT lookup unambiguous.
# ---------------------------------------------------------------------------

locals {
  public_by_az  = { for s in var.public_subnets : s.az => s }
  private_by_az = { for s in var.private_subnets : s.az => s }
  eks_by_az     = { for s in var.eks_subnets : s.az => s }
  data_by_az    = { for s in var.data_subnets : s.az => s }

  # Every AZ that holds a subnet needing NAT egress.
  private_azs = distinct(concat(
    [for s in var.private_subnets : s.az],
    [for s in var.eks_subnets : s.az],
    [for s in var.data_subnets : s.az],
  ))
}

resource "aws_subnet" "public" {
  for_each                = local.public_by_az
  vpc_id                  = local.vpc_id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = merge(var.project_tags, {
    Name = each.value.name
    Tier = "public"
    # Lets the AWS Load Balancer Controller auto-discover subnets for
    # internet-facing Ingress resources.
    "kubernetes.io/role/elb" = "1"
  })
}

resource "aws_subnet" "private" {
  vpc_id            = local.vpc_id
  for_each          = local.private_by_az
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = merge(var.project_tags, {
    Name = each.value.name
    Tier = "private-app"
  })
}

resource "aws_subnet" "eks" {
  for_each          = local.eks_by_az
  vpc_id            = local.vpc_id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = merge(var.project_tags, {
    Name = each.value.name
    Tier = "eks"
    # Auto-discovery for internal (VPC-only) Ingress resources.
    "kubernetes.io/role/internal-elb" = "1"
  })
}

resource "aws_subnet" "data" {
  for_each          = local.data_by_az
  vpc_id            = local.vpc_id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = merge(var.project_tags, {
    Name = each.value.name
    Tier = "data"
  })
}
