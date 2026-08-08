# 1. Security Group for the ALB
resource "aws_security_group" "alb_sg" {
  name        = "hera-alb-sg-${var.environment}"
  description = "Security group for Internal ALB"
  vpc_id      = var.vpc_id

  # Allow all internal VPC traffic to hit the Load Balancer ports
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr] # Restrict to your VPC
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Environment = var.environment }
}

# 2. The Internal Application Load Balancer
resource "aws_lb" "this" {
  name                       = "hera-alb-${var.environment}"
  internal                   = true
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.alb_sg.id]
  subnets                    = var.private_subnets
  enable_deletion_protection = var.enable_deletion_protection
  idle_timeout               = var.idle_timeout
  tags                       = { Environment = var.environment }
}

# 3. Target Groups (Created dynamically for every service)
resource "aws_lb_target_group" "this" {
  for_each = var.alb_services

  # Safely truncate the name to 32 characters to avoid AWS API errors
  name        = substr("${each.key}-tg-${var.environment}", 0, 32)
  port        = each.value.port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip" # CRITICAL: Do not change this to "instance"

  health_check {
    path                = each.value.health_check_path
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200,404" # Strictly require a 200 OK status
  }

  tags = { Environment = var.environment }
}

# 4. Listeners (Port-Based Routing: No priorities or path rules needed)
resource "aws_lb_listener" "service_listeners" {
  for_each = var.alb_services

  load_balancer_arn = aws_lb.this.arn
  port              = each.value.port
  protocol          = "HTTP"

  # Forward everything hitting this specific port directly to its Target Group
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this[each.key].arn
  }
}