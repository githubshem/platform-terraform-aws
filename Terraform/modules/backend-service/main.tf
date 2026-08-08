# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "this" {
  name              = "/ecs/${var.app_prefix}-${var.service_name}-${var.environment}"
  retention_in_days = var.cloudwatch_retention_days
}

# The Task Definition (Remains largely the same, referencing the log group)
resource "aws_ecs_task_definition" "this" {
  family                   = "${var.app_prefix}-${var.service_name}-${var.environment}"
  network_mode             = "awsvpc"
  requires_compatibilities = var.compute_type == "FARGATE" ? ["FARGATE"] : ["EC2"]
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  dynamic "volume" {
    for_each = var.host_volume_name != "" ? [1] : []
    content {
      name      = var.host_volume_name
      host_path = var.host_volume_path
    }
  }

  container_definitions = jsonencode([{
    name              = "${var.app_prefix}-${var.service_name}-${var.environment}"
    image             = var.image_url
    essential         = true
    memoryReservation = var.memory_reservation

    portMappings = [{
      containerPort = var.port
      hostPort      = var.port
      protocol      = "tcp"
    }]

    mountPoints = var.host_volume_name != "" ? [{
      sourceVolume  = var.host_volume_name
      containerPath = var.host_volume_path
      readOnly      = false
    }] : []

    environment = [
      for key, value in var.env_vars : {
        name  = key
        value = value
      }
    ]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.this.name
        "awslogs-region"        = var.aws_region
        "awslogs-stream-prefix" = "ecs"
      }
    }
  }])
}

# The ECS Service
resource "aws_ecs_service" "this" {
  name                          = "${var.app_prefix}-${var.service_name}-${var.environment}"
  cluster                       = var.cluster_id
  task_definition               = aws_ecs_task_definition.this.arn
  desired_count                 = var.task_count
  availability_zone_rebalancing = var.az_rebalancing
  force_new_deployment          = true

  # Parameterized Capacity Provider Strategy
  dynamic "capacity_provider_strategy" {
    for_each = var.compute_provider != "" ? [var.compute_provider] : []
    content {
      capacity_provider = capacity_provider_strategy.value
      weight            = var.cp_weight
    }
  }

  # NEW: Parameterized Placement Strategy (Binpack vs Spread)
  dynamic "ordered_placement_strategy" {
    for_each = var.placement_strategy_type != "" ? [1] : []
    content {
      type  = var.placement_strategy_type
      field = var.placement_strategy_field
    }
  }

  network_configuration {
    subnets          = var.private_subnets
    security_groups  = var.security_group_id
    assign_public_ip = false
  }

  lifecycle {
    ignore_changes = [desired_count]
  }
  #task_definition,
  dynamic "load_balancer" {
    for_each = toset(var.target_group_arn)
    content {
      target_group_arn = load_balancer.value
      container_name   = "${var.app_prefix}-${var.service_name}-${var.environment}"
      container_port   = var.port
    }
  }
}

# 1. Parameterized Scaling Target
resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = var.max_capacity
  min_capacity       = var.task_count
  resource_id        = "service/${var.cluster_name}/${aws_ecs_service.this.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# 2. Parameterized Target Tracking Policy
resource "aws_appautoscaling_policy" "ecs_cpu_policy" {
  name               = "${var.app_prefix}-${var.service_name}-cpu-autoscaling-${var.environment}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = var.cpu_target_value
    scale_out_cooldown = var.scale_out_cooldown
    scale_in_cooldown  = var.scale_in_cooldown
  }
}