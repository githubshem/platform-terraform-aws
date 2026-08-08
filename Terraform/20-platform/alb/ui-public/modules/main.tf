# 1. Security Group
resource "aws_security_group" "public_alb_sg" {
  count       = var.create_sg ? 1 : 0
  name        = "hera-zeus-public-alb-sg-${var.environment}"
  description = "Allow public HTTP and HTTPS traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge({ Environment = var.environment }, var.project_tags)
}

# 2. Public ALB
resource "aws_lb" "public" {
  name                       = "hera-zeus-public-alb-${var.environment}"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [var.create_sg ? aws_security_group.public_alb_sg[0].id : var.existing_sg_id]
  subnets                    = var.public_subnets
  idle_timeout               = 300
  enable_deletion_protection = true
  tags                       = merge({ Environment = var.environment }, var.project_tags)
}

# 3. Target Groups (For BOTH hera and zeus)
resource "aws_lb_target_group" "fe_targets" {
  for_each = var.ui_services

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
    matcher             = "200"
  }

  tags = merge({ Environment = var.environment, Portal = each.key }, var.project_tags)
}

# 4. Port 80 Listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.public.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# 5. Port 443 Listener
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.public.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.ssl_certificate_arn

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "404 Not Found"
      status_code  = "404"
    }
  }
}

# 6. Host-Based Routing Rules
resource "aws_lb_listener_rule" "host_routing" {
  for_each = var.ui_services

  listener_arn = aws_lb_listener.https.arn
  priority     = each.value.priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.fe_targets[each.key].arn
  }

  condition {
    host_header {
      values = each.value.host_headers
    }
  }
}