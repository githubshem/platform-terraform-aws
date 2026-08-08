# ==========================================
# SECURITY GROUP DEFINITIONS ONLY
# ==========================================

# SG 1: Public ALB
resource "aws_security_group" "alb_public" {
  name        = "${var.project_name}-${var.environment}-alb-public"
  description = "External ALB for ${var.environment}"
  vpc_id      = var.vpc_id
  tags = merge(var.project_tags, {
    Name = "${var.project_name}-${var.environment}-alb-public-sg"
    Env  = var.environment
  })
}

# SG 2: Private ALB
resource "aws_security_group" "alb_private" {
  name        = "${var.project_name}-${var.environment}-alb-private"
  description = "Internal ALB for ${var.environment}"
  vpc_id      = var.vpc_id
  tags = merge(var.project_tags, {
    Name = "${var.project_name}-${var.environment}-alb-private-sg"
    Env  = var.environment
  })
}

# SG 3: Unified Backend & Data Layer (ECS, RDS, Redis, OpenSearch, RabbitMQ)
resource "aws_security_group" "ecs_be" {
  name        = "${var.project_name}-${var.environment}-ecs-be-shared"
  description = "Unified SG for Backend ECS and all Data layers"
  vpc_id      = var.vpc_id
  tags = merge(var.project_tags, {
    Name = "${var.project_name}-${var.environment}-ecs-be-shared-sg"
    Env  = var.environment
  })
}

# SG 4: EKS worker nodes and pod ENIs
#
# Deliberately separate from ecs_be rather than reusing it. Both workload types
# need to reach the same data layer, but keeping them in distinct groups means a
# plan diff shows exactly which compute platform is being granted access, and
# either can be revoked without touching the other.
resource "aws_security_group" "eks_nodes" {
  name        = "${var.project_name}-${var.environment}-eks-nodes"
  description = "EKS worker nodes and pod ENIs for ${var.environment}"
  vpc_id      = var.vpc_id
  tags = merge(var.project_tags, {
    Name = "${var.project_name}-${var.environment}-eks-nodes-sg"
    Env  = var.environment
  })
}

# Local variable to safely combine port lists
locals {
  unified_backend_tcp_ports = concat(
    var.db_ports,
    var.redis_ports,
    var.opensearch_ports,
    var.rabbitmq_ports
  )
}
