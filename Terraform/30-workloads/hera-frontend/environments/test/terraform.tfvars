# ==========================================
# 1. CORE NETWORKING & CLUSTER CONFIGURATION
# ==========================================
environment  = "test"
cluster_name = "hera-fe-cluster"
aws_region   = "ap-southeast-1"

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
  Environment = "test"
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
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-test-hermes3-vue:latest"
    target_group_arn   = "arn:aws:elasticloadbalancing:ap-southeast-1:123456789012:targetgroup/hermes-tg-test/a2f062de1188961b"
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
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-test-artemis3-vue:latest"
    target_group_arn   = "arn:aws:elasticloadbalancing:ap-southeast-1:123456789012:targetgroup/artemis-tg-test/d651f429179712eb"
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
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-test-hestia3-vue:latest"
    target_group_arn   = "arn:aws:elasticloadbalancing:ap-southeast-1:123456789012:targetgroup/hestia-tg-test/daf6cd8a3aa683c8"
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
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-test-dionysus-vue:latest"
    target_group_arn   = "arn:aws:elasticloadbalancing:ap-southeast-1:123456789012:targetgroup/dionysus-tg-test/0dca87cc6be54972"
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
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-test-nike-vue:latest"
    target_group_arn   = "arn:aws:elasticloadbalancing:ap-southeast-1:123456789012:targetgroup/nike-tg-test/4e3e2a3863caeaeb"
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
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-test-station-hera3-vue:latest"
    target_group_arn   = "arn:aws:elasticloadbalancing:ap-southeast-1:123456789012:targetgroup/hera-tg-test/f6d8c1fe31e0bd27"
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
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-test-athena-vue:latest"
    target_group_arn   = "arn:aws:elasticloadbalancing:ap-southeast-1:123456789012:targetgroup/athena-tg-test/a35e03c7de1fef04"
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
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-test-orion3-vue:latest"
    target_group_arn   = "arn:aws:elasticloadbalancing:ap-southeast-1:123456789012:targetgroup/orion-tg-test/27c615690c14d485"
    min_count          = 1
    max_count          = 5
    cpu_target         = 70
    memory_target      = 80
  }
}