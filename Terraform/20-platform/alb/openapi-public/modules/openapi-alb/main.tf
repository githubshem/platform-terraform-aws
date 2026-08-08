resource "aws_security_group" "internal_alb_sg" {
  name        = "${var.alb_name}-sg-${var.environment}"
  description = "Allow inbound traffic from the VPC CIDR to Internal ALB for mapped services"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.alb_services
    content {
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

  tags = merge({ Name = "${var.alb_name}-sg-${var.environment}" }, var.project_tags)
}

resource "aws_lb" "internal_alb" {
  name               = var.alb_name
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.internal_alb_sg.id]
  subnets            = var.private_subnets

  tags = merge({ Name = var.alb_name, Environment = var.environment }, var.project_tags)
}

locals {
  public_service_names = sort(keys(var.alb_services))
  public_rule_priorities = {
    for idx, name in local.public_service_names :
    name => var.public_rule_priority_start + idx
  }
}

resource "aws_lb_target_group" "service_tg" {
  for_each = var.alb_services

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

  tags = merge({ Environment = var.environment, Service = each.key }, var.project_tags)
}

resource "aws_lb_target_group" "public_service_tg" {
  for_each = var.create_public_alb_rules ? var.alb_services : {}

  name        = substr("${var.public_tg_name_prefix}-${each.key}-tg", 0, 32)
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

  tags = merge({ Environment = var.environment, Service = each.key, Exposure = "public" }, var.project_tags)
}

resource "aws_lb_listener" "service_listener" {
  for_each = var.alb_services

  load_balancer_arn = aws_lb.internal_alb.arn
  port              = each.value.container_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.service_tg[each.key].arn
  }
}

resource "aws_lb_listener_rule" "public_host_routing" {
  for_each = var.create_public_alb_rules ? var.alb_services : {}

  listener_arn = var.public_alb_https_listener_arn
  priority     = local.public_rule_priorities[each.key]

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.public_service_tg[each.key].arn
  }

  condition {
    host_header {
      values = ["${each.key}-${var.environment}.${var.public_domain}"]
    }
  }
}
