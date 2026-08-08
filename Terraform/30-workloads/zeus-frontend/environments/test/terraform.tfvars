# ==========================================
# 1. CORE NETWORKING & CLUSTER CONFIGURATION
# ==========================================
environment  = "test"
cluster_name = "zeus-fe-cluster"
aws_region   = "ap-southeast-1"

# ==========================================
# 2. EC2 AUTO SCALING GROUP (INFRASTRUCTURE)
# ==========================================
ami_id             = "ami-0ddd444eee555fff"
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
  Project     = "plat-zeus-frontend"
  ManagedBy   = "terraform"
}

# ==========================================
# 5. MICROSERVICES
# ==========================================
fe_microservices = {
  "zeus-apollo" = {
    cpu                = 512
    memory             = 3072
    memory_reservation = 3072
    port               = 80
    min_count          = 0
    max_count          = 5
    cpu_target         = 70
    memory_target      = 80
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-test-apollo-vue:latest"
    target_group_arn   = "arn:aws:elasticloadbalancing:ap-southeast-1:123456789012:targetgroup/zeus-apollo-tg-test/b77d7cb35ad6b7ca"
  }
  "zeus" = {
    cpu                = 512
    memory             = 3072
    memory_reservation = 3072
    port               = 80
    min_count          = 0
    max_count          = 5
    cpu_target         = 70
    memory_target      = 80
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-test-zeus-vue:latest"
    target_group_arn   = "arn:aws:elasticloadbalancing:ap-southeast-1:123456789012:targetgroup/zeus-zeus-tg-test/58cfbf0e3c90c39f"
  }
  "zeus-artemis" = {
    cpu                = 512
    memory             = 3072
    memory_reservation = 3072
    port               = 80
    min_count          = 0
    max_count          = 5
    cpu_target         = 70
    memory_target      = 80
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-test-artemis-vue:latest"
    target_group_arn   = "arn:aws:elasticloadbalancing:ap-southeast-1:123456789012:targetgroup/zeus-artemis-tg-test/e40a1d499bbb2476"
  }
  "zeus-hestia" = {
    cpu                = 512
    memory             = 3072
    memory_reservation = 3072
    port               = 80
    min_count          = 0
    max_count          = 5
    cpu_target         = 70
    memory_target      = 80
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-test-hestia-vue:latest"
    target_group_arn   = "arn:aws:elasticloadbalancing:ap-southeast-1:123456789012:targetgroup/zeus-hestia-tg-test/239991e4b382d40d"
  }
  "zeus-demeter" = {
    cpu                = 512
    memory             = 3072
    memory_reservation = 3072
    port               = 80
    min_count          = 0
    max_count          = 5
    cpu_target         = 70
    memory_target      = 80
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-test-demeter-vue:latest"
    target_group_arn   = "arn:aws:elasticloadbalancing:ap-southeast-1:123456789012:targetgroup/zeus-demeter-tg-test/1efeaf51a08e4ed8"
  }
  "zeus-helios" = {
    cpu                = 512
    memory             = 3072
    memory_reservation = 3072
    port               = 80
    min_count          = 0
    max_count          = 5
    cpu_target         = 70
    memory_target      = 80
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-test-helios-vue:latest"
    target_group_arn   = "arn:aws:elasticloadbalancing:ap-southeast-1:123456789012:targetgroup/zeus-helios-tg-test/f75aed1900b98b4f"
  }
  "zeus-iris" = {
    cpu                = 512
    memory             = 3072
    memory_reservation = 3072
    port               = 80
    min_count          = 0
    max_count          = 5
    cpu_target         = 70
    memory_target      = 80
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-test-iris-vue:latest"
    target_group_arn   = "arn:aws:elasticloadbalancing:ap-southeast-1:123456789012:targetgroup/zeus-iris-tg-test/0a26705fd74a71ed"
  }
  "zeus-proteus" = {
    cpu                = 512
    memory             = 3072
    memory_reservation = 3072
    port               = 80
    min_count          = 0
    max_count          = 5
    cpu_target         = 70
    memory_target      = 80
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-test-proteus-vue:latest"
    target_group_arn   = "arn:aws:elasticloadbalancing:ap-southeast-1:123456789012:targetgroup/zeus-proteus-tg-test/b3a3ff17f25018f0"
  }
  "zeus-kronos" = {
    cpu                = 512
    memory             = 3072
    memory_reservation = 3072
    port               = 80
    min_count          = 0
    max_count          = 5
    cpu_target         = 70
    memory_target      = 80
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-test-kronos-vue:latest"
    target_group_arn   = "arn:aws:elasticloadbalancing:ap-southeast-1:123456789012:targetgroup/zeus-kronos-tg-test/5d89ea6f8abadd80"
  }
  "zeus-morpheus" = {
    cpu                = 512
    memory             = 3072
    memory_reservation = 3072
    port               = 80
    min_count          = 0
    max_count          = 5
    cpu_target         = 70
    memory_target      = 80
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-test-morpheus-vue:latest"
    target_group_arn   = "arn:aws:elasticloadbalancing:ap-southeast-1:123456789012:targetgroup/zeus-morpheus-tg-test/251675256e772b73"
  }
  "zeus-hades" = {
    cpu                = 512
    memory             = 3072
    memory_reservation = 3072
    port               = 80
    min_count          = 0
    max_count          = 5
    cpu_target         = 70
    memory_target      = 80
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-test-hades-vue:latest"
    target_group_arn   = "arn:aws:elasticloadbalancing:ap-southeast-1:123456789012:targetgroup/zeus-hades-tg-test/c8efde79e9139447"
  }
  "zeus-hephaestus" = {
    cpu                = 512
    memory             = 3072
    memory_reservation = 3072
    port               = 80
    min_count          = 0
    max_count          = 5
    cpu_target         = 70
    memory_target      = 80
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-test-hephaestus-vue:latest"
    target_group_arn   = "arn:aws:elasticloadbalancing:ap-southeast-1:123456789012:targetgroup/zeus-hephaestus-tg-test/bf384e99a783e37a"
  }
  "zeus-poseidon" = {
    cpu                = 512
    memory             = 3072
    memory_reservation = 3072
    port               = 80
    min_count          = 0
    max_count          = 5
    cpu_target         = 70
    memory_target      = 80
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-test-poseidon-vue:latest"
    target_group_arn   = "arn:aws:elasticloadbalancing:ap-southeast-1:123456789012:targetgroup/zeus-poseidon-tg-test/b6d6bec1ea0c7038"
  }
  "zeus-ares-admin" = {
    cpu                = 512
    memory             = 3072
    memory_reservation = 3072
    port               = 80
    min_count          = 0
    max_count          = 5
    cpu_target         = 70
    memory_target      = 80
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-test-ares-admin-vue:latest"
    target_group_arn   = "arn:aws:elasticloadbalancing:ap-southeast-1:123456789012:targetgroup/zeus-ares-admin-tg-test/9a97ed8fa840b0af"
  }
  "zeus-triton" = {
    cpu                = 512
    memory             = 3072
    memory_reservation = 3072
    port               = 80
    min_count          = 0
    max_count          = 5
    cpu_target         = 70
    memory_target      = 80
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-test-triton-vue:latest"
    target_group_arn   = "arn:aws:elasticloadbalancing:ap-southeast-1:123456789012:targetgroup/zeus-triton-tg-test/21e5d666b1243b16"
  }
  "zeus-arachne-client" = {
    cpu                = 512
    memory             = 3072
    memory_reservation = 3072
    port               = 80
    min_count          = 0
    max_count          = 5
    cpu_target         = 70
    memory_target      = 80
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-test-arachne-client-vue:latest"
    target_group_arn   = "arn:aws:elasticloadbalancing:ap-southeast-1:123456789012:targetgroup/zeus-arachne-client-tg-test/07ef263a6698f5be"
  }
  "zeus-hermes" = {
    cpu                = 512
    memory             = 3072
    memory_reservation = 3072
    port               = 80
    min_count          = 0
    max_count          = 5
    cpu_target         = 70
    memory_target      = 80
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-test-hermes-vue:latest"
    target_group_arn   = "arn:aws:elasticloadbalancing:ap-southeast-1:123456789012:targetgroup/zeus-hermes-tg-test/2f497bb31a273f1e"
  }
  "zeus-orion" = {
    cpu                = 512
    memory             = 3072
    memory_reservation = 3072
    port               = 80
    min_count          = 0
    max_count          = 5
    cpu_target         = 70
    memory_target      = 80
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-test-orion-vue:latest"
    target_group_arn   = "arn:aws:elasticloadbalancing:ap-southeast-1:123456789012:targetgroup/zeus-orion-tg-test/978f3e9a41f81131"
  }
  "zeus-ares-client" = {
    cpu                = 512
    memory             = 3072
    memory_reservation = 3072
    port               = 80
    min_count          = 0
    max_count          = 5
    cpu_target         = 70
    memory_target      = 80
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-test-ares-client-vue:latest"
    target_group_arn   = "arn:aws:elasticloadbalancing:ap-southeast-1:123456789012:targetgroup/zeus-ares-client-tg-test/b3360df4ee94ed52"
  }
  "zeus-thanatos" = {
    cpu                = 512
    memory             = 3072
    memory_reservation = 3072
    port               = 80
    min_count          = 0
    max_count          = 5
    cpu_target         = 70
    memory_target      = 80
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-test-zeus-thanatos-vue:latest"
    target_group_arn   = "arn:aws:elasticloadbalancing:ap-southeast-1:123456789012:targetgroup/zeus-thanatos-tg-test/1e5ea2d0cfd14c2a"
  }
}