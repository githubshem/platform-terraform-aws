# ==========================================
# 1. CORE NETWORKING & CLUSTER CONFIGURATION
# ==========================================
environment  = "prod"
cluster_name = "hera-fe-cluster"
aws_region   = "ap-southeast-1"
# FE Security Groups (Allowing port 80 from the ALB)

# ==========================================
# 2. EC2 AUTO SCALING GROUP (INFRASTRUCTURE)
# ==========================================
ami_id             = "ami-0ddd444eee555fff" # Amazon ECS-Optimized AMI
ec2_instance_type  = "m6i.large"
min_size           = 0
max_size           = 10
warm_pool_size     = 0
target_capacity    = 100
default_cp_weight  = 100
container_insights = "disabled"

# ==========================================
# 3. IAM ROLES & LOGGING
# ==========================================
ecs_instance_profile_name = "ecsInstanceRole"
ecs_execution_role_arn    = "arn:aws:iam::123456789012:role/ecsTaskExecutionRole"
ecs_task_role_arn         = "arn:aws:iam::123456789012:role/ecsTaskRole"
cloudwatch_retention_days = 7

# ==========================================
# 4. PLACEMENT STRATEGY & TAGGING
# ==========================================
placement_strategy_type  = "binpack"
placement_strategy_field = "memory"

project_tags = {
  Environment = "prod"
  Project     = "plat-hera-frontend"
  ManagedBy   = "terraform"
}

# ==========================================
# 5. MICROSERVICES (WITH TASK AUTO SCALING)
# ==========================================
fe_microservices = {
  "hermes3" = {
    cpu                = 512
    memory             = 3072
    memory_reservation = 3072
    port               = 80
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-prod-hermes3-vue:latest"
    target_group_arn   = "arn:aws:elasticloadbalancing:ap-southeast-1:123456789012:targetgroup/hermes-tg-prod/e3ef5a1b1177ac34"
    min_count          = 1
    max_count          = 5
    cpu_target         = 70
    memory_target      = 80
  }
  "artemis3" = {
    cpu                = 512
    memory             = 3072
    memory_reservation = 3072
    port               = 80
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-prod-artemis3-vue:latest"
    target_group_arn   = "arn:aws:elasticloadbalancing:ap-southeast-1:123456789012:targetgroup/artemis-tg-prod/839cc7dd9da2c609"
    min_count          = 1
    max_count          = 5
    cpu_target         = 70
    memory_target      = 80
  }
  "hestia3" = {
    cpu                = 512
    memory             = 3072
    memory_reservation = 3072
    port               = 80
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-prod-hestia3-vue:latest"
    target_group_arn   = "arn:aws:elasticloadbalancing:ap-southeast-1:123456789012:targetgroup/hestia-tg-prod/a017109ec2e04277"
    min_count          = 1
    max_count          = 5
    cpu_target         = 70
    memory_target      = 80
  }
  "dionysus" = {
    cpu                = 512
    memory             = 3072
    memory_reservation = 3072
    port               = 80
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-prod-dionysus-vue:latest"
    target_group_arn   = "arn:aws:elasticloadbalancing:ap-southeast-1:123456789012:targetgroup/dionysus-tg-prod/461422b3b9f8a8fe"
    min_count          = 1
    max_count          = 5
    cpu_target         = 70
    memory_target      = 80
  }
  "nike" = {
    cpu                = 512
    memory             = 3072
    memory_reservation = 3072
    port               = 80
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-prod-nike-vue:latest"
    target_group_arn   = "arn:aws:elasticloadbalancing:ap-southeast-1:123456789012:targetgroup/nike-tg-prod/1994c4dedb2c2e96"
    min_count          = 1
    max_count          = 5
    cpu_target         = 70
    memory_target      = 80
  }
  "hera3" = {
    cpu                = 512
    memory             = 3072
    memory_reservation = 3072
    port               = 80
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-prod-station-hera3-vue:latest"
    target_group_arn   = "arn:aws:elasticloadbalancing:ap-southeast-1:123456789012:targetgroup/hera-tg-prod/e7a88133dc8df9d2"
    min_count          = 1
    max_count          = 5
    cpu_target         = 70
    memory_target      = 80
  }
  "athena" = {
    cpu                = 512
    memory             = 3072
    memory_reservation = 3072
    port               = 80
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-prod-athena-vue:latest"
    target_group_arn   = "arn:aws:elasticloadbalancing:ap-southeast-1:123456789012:targetgroup/athena-tg-prod/6093b9aea57a8725"
    min_count          = 1
    max_count          = 5
    cpu_target         = 70
    memory_target      = 80
  }
  "orion3" = {
    cpu                = 512
    memory             = 3072
    memory_reservation = 3072
    port               = 80
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-prod-orion3-vue:latest"
    target_group_arn   = "arn:aws:elasticloadbalancing:ap-southeast-1:123456789012:targetgroup/orion-tg-prod/d32062279dfd00ed"
    min_count          = 1
    max_count          = 5
    cpu_target         = 70
    memory_target      = 80
  }
}