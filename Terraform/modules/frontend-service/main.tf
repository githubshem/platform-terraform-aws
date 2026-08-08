# 1. Security Group for ECS Tasks (Conditionally created or reused)
resource "aws_security_group" "ecs_tasks_sg" {
  count       = var.existing_ecs_tasks_sg_id == null ? 1 : 0
  name        = "fe-tasks-sg-${var.environment}"
  description = "Allow inbound access from the Public ALB"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [var.public_alb_sg_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.project_tags
}

# 2. CloudWatch Log Groups
resource "aws_cloudwatch_log_group" "service_logs" {
  for_each          = var.fe_microservices
  name              = "/ecs/${each.key}-${var.environment}"
  retention_in_days = var.cloudwatch_retention_days
  tags              = merge({ Microservice = each.key }, var.project_tags)
}

# 3. ECS Task Definitions
resource "aws_ecs_task_definition" "service_tasks" {
  for_each = var.fe_microservices

  family                   = "${each.key}-portal-taskdef-${var.environment}"
  network_mode             = "awsvpc" # Modern AWS networking
  requires_compatibilities = ["EC2"]
  execution_role_arn       = var.ecs_execution_role_arn
  task_role_arn            = var.ecs_task_role_arn
  cpu                      = each.value.cpu
  memory                   = each.value.memory

  container_definitions = jsonencode([
    {
      name              = "${each.key}-container"
      image             = each.value.image
      essential         = true
      memoryReservation = each.value.memory_reservation
      portMappings = [
        {
          containerPort = each.value.port
          hostPort      = each.value.port
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/${each.key}-${var.environment}"
          "awslogs-region"        = "ap-southeast-1"
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  tags = merge({ Microservice = each.key }, var.project_tags)
}



# 4. ECS Services
resource "aws_ecs_service" "services" {
  for_each = var.fe_microservices

  name            = "${each.key}-portal-${var.environment}"
  cluster         = "${var.cluster_name}-${var.environment}"
  task_definition = aws_ecs_task_definition.service_tasks[each.key].arn
  #desired_count   = each.value.count
  desired_count        = each.value.min_count
  force_new_deployment = true

  # Use the EC2 Capacity Provider created in the other module
  capacity_provider_strategy {
    capacity_provider = var.capacity_provider_name
    weight            = 100
  }

  # Apply the binpack placement strategy requested
  ordered_placement_strategy {
    type  = var.placement_strategy_type
    field = var.placement_strategy_field
  }

  network_configuration {
    subnets = var.private_subnets
    # Logic: If existing ID is provided, use it. Otherwise, use the one we created [0].id
    security_groups = [
      var.existing_ecs_tasks_sg_id != null ? var.existing_ecs_tasks_sg_id : aws_security_group.ecs_tasks_sg[0].id
    ]
  }

  load_balancer {
    target_group_arn = each.value.target_group_arn
    container_name   = "${each.key}-container"
    container_port   = each.value.port
  }

  # Prevent Terraform from overriding Jenkins image deployments
  lifecycle {
    ignore_changes = [task_definition, desired_count]
  }

  tags = merge({ Microservice = each.key }, var.project_tags)
}
# 5. App Auto Scaling Target (Registers the ECS Service for scaling)
resource "aws_appautoscaling_target" "ecs_target" {
  for_each = var.fe_microservices

  max_capacity = each.value.max_count
  min_capacity = each.value.min_count

  # FIX: Use cluster_name instead of ecs_cluster_id (ARN) to prevent scaling failures
  resource_id        = "service/${var.cluster_name}-${var.environment}/${aws_ecs_service.services[each.key].name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# 6. CPU Target Tracking Policy
resource "aws_appautoscaling_policy" "cpu_policy" {
  for_each = var.fe_microservices

  name               = "${each.key}-cpu-target-tracking"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target[each.key].resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target[each.key].scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target[each.key].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = each.value.cpu_target

    # NEW: Added cooldowns to match your BE infrastructure
    scale_out_cooldown = lookup(each.value, "scale_out_cooldown", 180)
    scale_in_cooldown  = lookup(each.value, "scale_in_cooldown", 180)
  }
}

# 7. Memory Target Tracking Policy
resource "aws_appautoscaling_policy" "memory_policy" {
  for_each = var.fe_microservices

  name               = "${each.key}-memory-target-tracking"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target[each.key].resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target[each.key].scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target[each.key].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
    target_value = each.value.memory_target

    # NEW: Added cooldowns to match your BE infrastructure
    scale_out_cooldown = lookup(each.value, "scale_out_cooldown", 180)
    scale_in_cooldown  = lookup(each.value, "scale_in_cooldown", 180)
  }
}
# hera-frontend previously used a copy of this module that always created the
# task security group, so its address was aws_security_group.ecs_tasks_sg. This
# module makes creation conditional (count), which moves the address to [0].
# Without this block Terraform reads that as destroy-and-recreate; the SG is
# attached to running tasks, so that would be an outage rather than a refactor.
# For zeus-frontend, which already used the conditional form, this is a no-op.
moved {
  from = aws_security_group.ecs_tasks_sg
  to   = aws_security_group.ecs_tasks_sg[0]
}
