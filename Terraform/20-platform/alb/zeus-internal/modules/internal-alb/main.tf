# ==========================================
# 1. SECURITY GROUP
# ==========================================
resource "aws_security_group" "internal_alb_sg" {
  name        = "${var.alb_name}-sg-${var.environment}"
  description = "Allow inbound traffic from 10.10.0.0/16 to Internal ALB for mapped services"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.alb_services
    content {
      # CRITICAL FIX: Extract the container_port from the object
      from_port   = ingress.value.container_port
      to_port     = ingress.value.container_port
      protocol    = "tcp"
      cidr_blocks = [var.vpc_cidr_block]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.alb_name}-sg-${var.environment}"
  }
}

# ==========================================
# 2. THE INTERNAL ALB
# ==========================================
resource "aws_lb" "internal_alb" {
  # This resolves to: zeus-alb-prod
  name               = "${var.alb_name}-${var.environment}"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.internal_alb_sg.id]
  subnets            = var.private_subnets

  tags = {
    Name = "${var.alb_name}-${var.environment}"
  }
}

# ==========================================
# DYNAMIC TARGET GROUPS
# ==========================================
resource "aws_lb_target_group" "service_tg" {
  for_each = var.alb_services

  # (Note: I see you went back to '-tg-'. If you get the immutable error again, change this to '-v2-')
  name        = substr("${each.key}-tg-${var.environment}", 0, 32)
  port        = each.value.container_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = each.value.health_check_path
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200-499"
  }

  tags = merge({ Environment = var.environment, Portal = each.key }, var.project_tags)
}

# ==========================================
# DYNAMIC LISTENERS
# ==========================================
resource "aws_lb_listener" "service_listener" {
  for_each = var.alb_services

  load_balancer_arn = aws_lb.internal_alb.arn

  # CRITICAL UPDATE: You must change this to each.value.container_port as well!
  port     = each.value.container_port
  protocol = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.service_tg[each.key].arn
  }
}