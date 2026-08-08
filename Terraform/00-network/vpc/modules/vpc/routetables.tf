# ---------------------------------------------------------------------------
# Route tables
#
# One public route table via the internet gateway, and one PRIVATE ROUTE TABLE
# PER AZ. The per-AZ split matters: with a single shared private table, every
# private subnet egresses through one NAT gateway regardless of how many exist,
# which reintroduces both the single point of failure and a cross-AZ data
# transfer charge on every outbound packet.
# ---------------------------------------------------------------------------

resource "aws_route_table" "public" {
  vpc_id = local.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = local.igw_id
  }

  tags = merge(var.project_tags, { Name = "${var.vpc_name}-rt-public" })
}

resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

locals {
  # An AZ uses its own NAT gateway when one exists there; otherwise it falls back
  # to the first NAT in the list. The fallback keeps a deliberately cost-reduced
  # single-NAT deployment working instead of failing the plan.
  nat_gateway_for_az = {
    for az in local.private_azs :
    az => contains(var.nat_subnets, az) ? az : var.nat_subnets[0]
  }
}

resource "aws_route_table" "private" {
  for_each = toset(local.private_azs)
  vpc_id   = local.vpc_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat[local.nat_gateway_for_az[each.key]].id
  }

  tags = merge(var.project_tags, { Name = "${var.vpc_name}-rt-private-${each.key}" })
}

resource "aws_route_table_association" "private" {
  for_each       = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.key].id
}

resource "aws_route_table_association" "eks" {
  for_each       = aws_subnet.eks
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.key].id
}

resource "aws_route_table_association" "data" {
  for_each       = aws_subnet.data
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.key].id
}
