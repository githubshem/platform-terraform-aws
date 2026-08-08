# -------------------------------------------------------------
# 1. CORE CLUSTER
# -------------------------------------------------------------
resource "aws_ecs_cluster" "this" {
  name = "${var.app_prefix}-${var.environment}-${var.cluster_name}"

  setting {
    name  = "containerInsights"
    value = var.container_insights
  }
}

# -------------------------------------------------------------
# 2. PRIMARY ASG & CAPACITY PROVIDER (Shared Nodes)
# -------------------------------------------------------------
resource "aws_launch_template" "primary_lt" {
  name_prefix            = "${var.app_prefix}-primary-${var.environment}-"
  image_id               = var.ami_id
  instance_type          = var.ec2_instance_type
  vpc_security_group_ids = var.security_group_ids
  key_name               = var.ec2_key_name

  iam_instance_profile {
    name = var.ecs_instance_profile_name
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    echo ECS_CLUSTER=${aws_ecs_cluster.this.name} >> /etc/ecs/ecs.config
  EOF
  )
}

resource "aws_autoscaling_group" "primary_asg" {
  name                = "${var.app_prefix}-primary-${var.cluster_name}-${var.environment}"
  vpc_zone_identifier = var.private_subnets
  min_size            = var.min_size
  max_size            = var.max_size
  desired_capacity    = var.min_size

  launch_template {
    id      = aws_launch_template.primary_lt.id
    version = "$Latest"
  }

  dynamic "warm_pool" {
    for_each = var.warm_pool_size > 0 ? [1] : []
    content {
      pool_state                  = "Stopped"
      min_size                    = var.warm_pool_size
      max_group_prepared_capacity = var.warm_pool_size
      instance_reuse_policy {
        reuse_on_scale_in = false
      }
    }
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = ""
    propagate_at_launch = true
  }
  dynamic "tag" {
    for_each = var.tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}

resource "aws_ecs_capacity_provider" "primary_cp" {
  name = "${var.app_prefix}-primary-${var.cluster_name}-cp-${var.environment}"
  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.primary_asg.arn
    managed_termination_protection = "DISABLED"
    managed_scaling {
      status          = "ENABLED"
      target_capacity = var.target_capacity
    }
  }
}

# -------------------------------------------------------------
# 3. DYNAMIC DEDICATED CAPACITY PROVIDERS (E.g. Eureka/Config)
# -------------------------------------------------------------
resource "aws_launch_template" "dedicated_lt" {
  for_each               = var.dedicated_capacity_providers
  name_prefix            = "${var.app_prefix}-dedicated-${each.key}-"
  image_id               = var.ami_id
  instance_type          = each.value.instance_type
  vpc_security_group_ids = var.security_group_ids

  iam_instance_profile {
    name = var.ecs_instance_profile_name
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    echo ECS_CLUSTER=${aws_ecs_cluster.this.name} >> /etc/ecs/ecs.config
  EOF
  )
}

resource "aws_autoscaling_group" "dedicated_asg" {
  for_each            = var.dedicated_capacity_providers
  name                = "${var.app_prefix}-dedicated-${each.key}-asg"
  vpc_zone_identifier = var.private_subnets
  min_size            = each.value.min_size
  max_size            = each.value.max_size
  desired_capacity    = each.value.min_size

  launch_template {
    id      = aws_launch_template.dedicated_lt[each.key].id
    version = "$Latest"
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = ""
    propagate_at_launch = true
  }
}

resource "aws_ecs_capacity_provider" "dedicated_cp" {
  for_each = var.dedicated_capacity_providers
  name     = each.key # The key in the map becomes the CP name

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.dedicated_asg[each.key].arn
    managed_termination_protection = "DISABLED"
    managed_scaling {
      status          = "ENABLED"
      target_capacity = 100
    }
  }
}

# 4. CLUSTER CAPACITY PROVIDER ATTACHMENT
resource "aws_ecs_cluster_capacity_providers" "this" {
  cluster_name = aws_ecs_cluster.this.name

  capacity_providers = concat(
    [aws_ecs_capacity_provider.primary_cp.name, "FARGATE", "FARGATE_SPOT"],
    [for cp in aws_ecs_capacity_provider.dedicated_cp : cp.name]
  )

  # Parameterized Default Strategy Weight
  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.primary_cp.name
    weight            = var.default_cp_weight
  }
}