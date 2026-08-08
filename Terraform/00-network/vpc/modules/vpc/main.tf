# 1. VPC Configuration (Conditional Creation or Lookup)
resource "aws_vpc" "main" {
  count                = var.create_vpc ? 1 : 0
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = merge(var.project_tags, { Name = var.vpc_name })
}

data "aws_vpc" "existing" {
  count = var.create_vpc ? 0 : 1
  id    = var.existing_vpc_id
}

# Local helper to cleanly reference the active VPC ID across other files
locals {
  vpc_id = var.create_vpc ? aws_vpc.main[0].id : data.aws_vpc.existing[0].id
}

# 2. Internet Gateway Configuration
resource "aws_internet_gateway" "igw" {
  count  = var.create_vpc ? 1 : 0
  vpc_id = local.vpc_id
  tags   = merge(var.project_tags, { Name = "${var.vpc_name}-igw" })
}

data "aws_internet_gateway" "existing" {
  count = var.create_vpc ? 0 : 1
  filter {
    name   = "attachment.vpc-id"
    values = [local.vpc_id]
  }
}

# Local helper to cleanly reference the active IGW ID
locals {
  igw_id = var.create_vpc ? aws_internet_gateway.igw[0].id : data.aws_internet_gateway.existing[0].id
}

# 3. NAT Gateway Resources
#    One Elastic IP and one NAT gateway per AZ listed in nat_subnets.
resource "aws_eip" "nat" {
  for_each = toset(var.nat_subnets)
  domain   = "vpc"
  tags     = merge(var.project_tags, { Name = "${var.vpc_name}-nat-${each.value}" })
}

resource "aws_nat_gateway" "nat" {
  for_each      = toset(var.nat_subnets)
  allocation_id = aws_eip.nat[each.value].id
  # References the public subnet created in subnets.tf
  subnet_id = aws_subnet.public[each.value].id
  tags      = merge(var.project_tags, { Name = "${var.vpc_name}-nat-${each.value}" })

  depends_on = [aws_internet_gateway.igw]
}

# 4. Flow Logs
#    Records accepted and rejected traffic for the whole VPC. Without this there
#    is no record of who talked to what, which makes any incident review guesswork.
resource "aws_cloudwatch_log_group" "flow_logs" {
  count             = var.enable_flow_logs ? 1 : 0
  name              = "/aws/vpc/${var.vpc_name}/flow-logs"
  retention_in_days = var.flow_log_retention_days
  kms_key_id        = var.flow_log_kms_key_arn != "" ? var.flow_log_kms_key_arn : null
  tags              = merge(var.project_tags, { Name = "${var.vpc_name}-flow-logs" })
}

data "aws_iam_policy_document" "flow_logs_assume" {
  count = var.enable_flow_logs ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "flow_logs_write" {
  count = var.enable_flow_logs ? 1 : 0

  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams",
    ]
    resources = ["${aws_cloudwatch_log_group.flow_logs[0].arn}:*"]
  }
}

resource "aws_iam_role" "flow_logs" {
  count              = var.enable_flow_logs ? 1 : 0
  name               = "${var.vpc_name}-flow-logs"
  assume_role_policy = data.aws_iam_policy_document.flow_logs_assume[0].json
  tags               = var.project_tags
}

resource "aws_iam_role_policy" "flow_logs" {
  count  = var.enable_flow_logs ? 1 : 0
  name   = "${var.vpc_name}-flow-logs"
  role   = aws_iam_role.flow_logs[0].id
  policy = data.aws_iam_policy_document.flow_logs_write[0].json
}

resource "aws_flow_log" "this" {
  count                = var.enable_flow_logs ? 1 : 0
  vpc_id               = local.vpc_id
  traffic_type         = "ALL"
  log_destination_type = "cloud-watch-logs"
  log_destination      = aws_cloudwatch_log_group.flow_logs[0].arn
  iam_role_arn         = aws_iam_role.flow_logs[0].arn
  tags                 = merge(var.project_tags, { Name = "${var.vpc_name}-flow-logs" })
}
