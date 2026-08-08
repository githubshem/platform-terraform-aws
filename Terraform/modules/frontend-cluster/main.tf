# 1. The ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "${var.cluster_name}-${var.environment}"
  tags = var.project_tags
}

# 2. Launch Template for EC2 Instances
resource "aws_launch_template" "ecs_lt" {
  name_prefix   = "${var.cluster_name}-lt-"
  image_id      = var.ami_id
  instance_type = var.ec2_instance_type

  iam_instance_profile {
    name = var.ecs_instance_profile_name
  }

  # ==========================================
  # FIX: Tell ECS to wait for the Warm Pool to finish waking up!
  # ==========================================
  user_data = base64encode(<<EOF
#!/bin/bash
echo ECS_CLUSTER=${aws_ecs_cluster.main.name} >> /etc/ecs/ecs.config
echo ECS_WARM_POOLS_CHECK=true >> /etc/ecs/ecs.config
EOF
  )

  tags = var.project_tags
}

# 3. Auto Scaling Group (With Warm Pool)
resource "aws_autoscaling_group" "ecs_asg" {
  name                = "${var.cluster_name}-asg-${var.environment}"
  vpc_zone_identifier = var.private_subnets
  min_size            = var.min_size
  max_size            = var.max_size
  force_delete        = true

  launch_template {
    id      = aws_launch_template.ecs_lt.id
    version = "$Latest"
  }

  # NEW: Keep instances pre-warmed for fast scaling!
  warm_pool {
    pool_state = "Stopped"
    min_size   = var.warm_pool_size
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = true
    propagate_at_launch = true
  }
}

# 4. Capacity Provider
resource "aws_ecs_capacity_provider" "main" {
  name = "${var.cluster_name}-cp-${var.environment}"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.ecs_asg.arn
    managed_termination_protection = "DISABLED"

    managed_scaling {
      maximum_scaling_step_size = 2
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = var.target_capacity
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name       = aws_ecs_cluster.main.name
  capacity_providers = [aws_ecs_capacity_provider.main.name]
}
