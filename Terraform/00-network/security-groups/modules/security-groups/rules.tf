# ==========================================
# PUBLIC ALB RULES
# ==========================================

resource "aws_security_group_rule" "alb_public_ingress_http" {
  for_each          = toset([for p in var.fe_http_ports : tostring(p)])
  type              = "ingress"
  from_port         = tonumber(each.value)
  to_port           = tonumber(each.value)
  protocol          = "tcp"
  cidr_blocks       = var.egress_cidr_blocks
  security_group_id = aws_security_group.alb_public.id
}

resource "aws_security_group_rule" "alb_public_ingress_https" {
  for_each          = toset([for p in var.fe_https_ports : tostring(p)])
  type              = "ingress"
  from_port         = tonumber(each.value)
  to_port           = tonumber(each.value)
  protocol          = "tcp"
  cidr_blocks       = var.egress_cidr_blocks
  security_group_id = aws_security_group.alb_public.id
}

resource "aws_security_group_rule" "alb_public_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = var.egress_cidr_blocks
  security_group_id = aws_security_group.alb_public.id
}

# ==========================================
# PRIVATE ALB RULES
# ==========================================

resource "aws_security_group_rule" "alb_private_ingress_from_public" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.alb_public.id
  security_group_id        = aws_security_group.alb_private.id
}

resource "aws_security_group_rule" "alb_private_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = var.egress_cidr_blocks
  security_group_id = aws_security_group.alb_private.id
}

# ==========================================
# UNIFIED BACKEND & DATA LAYER RULES (ecs-be)
# ==========================================

# Allow Private ALB to route traffic into your ECS Containers
resource "aws_security_group_rule" "be_ingress_from_private_alb" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.alb_private.id
  security_group_id        = aws_security_group.ecs_be.id
}

# Self-referencing rule allowing ECS, RDS, Redis, OS, and RabbitMQ to talk to each other
resource "aws_security_group_rule" "be_self_ingress_tcp" {
  for_each                 = toset([for p in local.unified_backend_tcp_ports : tostring(p)])
  type                     = "ingress"
  from_port                = tonumber(each.value)
  to_port                  = tonumber(each.value)
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ecs_be.id
  security_group_id        = aws_security_group.ecs_be.id
}

# Self-referencing UDP rule for GELF logging
resource "aws_security_group_rule" "be_self_ingress_gelf_udp" {
  for_each                 = toset([for p in var.gelf_ports : tostring(p)])
  type                     = "ingress"
  from_port                = tonumber(each.value)
  to_port                  = tonumber(each.value)
  protocol                 = "udp"
  source_security_group_id = aws_security_group.ecs_be.id
  security_group_id        = aws_security_group.ecs_be.id
}

resource "aws_security_group_rule" "be_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = var.egress_cidr_blocks
  security_group_id = aws_security_group.ecs_be.id
}
# ==========================================
# EKS NODE RULES (eks-nodes)
# ==========================================

# Node-to-node and pod-to-pod. The VPC CNI puts pods on VPC IPs inside this
# group, so cluster-internal traffic is self-referencing rather than CIDR based.
resource "aws_security_group_rule" "eks_self_ingress" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.eks_nodes.id
  security_group_id        = aws_security_group.eks_nodes.id
  description              = "Node and pod traffic within the cluster"
}

# Ingress from the internal ALB, so Ingress resources can reach pods.
resource "aws_security_group_rule" "eks_ingress_from_private_alb" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.alb_private.id
  security_group_id        = aws_security_group.eks_nodes.id
  description              = "Internal ALB to pods"
}

# The point of the separate group: EKS pods reach the shared data layer on the
# same ports ECS uses, granted explicitly rather than by sharing ecs_be.
resource "aws_security_group_rule" "be_ingress_from_eks_nodes" {
  for_each                 = toset([for p in local.unified_backend_tcp_ports : tostring(p)])
  type                     = "ingress"
  from_port                = tonumber(each.value)
  to_port                  = tonumber(each.value)
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.eks_nodes.id
  security_group_id        = aws_security_group.ecs_be.id
  description              = "EKS pods to shared data layer"
}

resource "aws_security_group_rule" "eks_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = var.egress_cidr_blocks
  security_group_id = aws_security_group.eks_nodes.id
  description       = "Node egress for image pulls, AWS APIs, and add-on traffic"
}
