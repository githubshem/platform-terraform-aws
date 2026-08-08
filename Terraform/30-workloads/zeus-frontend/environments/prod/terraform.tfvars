# ==========================================
# 1. CORE NETWORKING & CLUSTER CONFIGURATION
# ==========================================
environment  = "prod"
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
  Environment = "prod"
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
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-prod-apollo-vue:latest"
    target_group_arn   = "arn:aws:elasticloadbalancing:ap-southeast-1:123456789012:targetgroup/zeus-apollo-tg-prod/f65bfe6fd6849b8f"
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
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-prod-zeus-vue:latest"
    target_group_arn   = "arn:aws:elasticloadbalancing:ap-southeast-1:123456789012:targetgroup/zeus-zeus-tg-prod/619b2ff1a3b2942b"
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
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-prod-artemis-vue:latest"
    target_group_arn   = "arn:aws:elasticloadbalancing:ap-southeast-1:123456789012:targetgroup/zeus-artemis-tg-prod/4575eff524bcdef7"
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
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-prod-hestia-vue:latest"
    target_group_arn   = "arn:aws:elasticloadbalancing:ap-southeast-1:123456789012:targetgroup/zeus-hestia-tg-prod/e805da898685ec86"
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
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-prod-demeter-vue:latest"
    target_group_arn   = "arn:aws:elasticloadbalancing:ap-southeast-1:123456789012:targetgroup/zeus-demeter-tg-prod/346a333a9ac025e5"
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
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-prod-helios-vue:latest"
    target_group_arn   = "arn:aws:elasticloadbalancing:ap-southeast-1:123456789012:targetgroup/zeus-helios-tg-prod/d233e9e9c1eb04db"
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
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-prod-iris-vue:latest"
    target_group_arn   = "arn:aws:elasticloadbalancing:ap-southeast-1:123456789012:targetgroup/zeus-iris-tg-prod/85e7dd224f91918e"
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
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-prod-proteus-vue:latest"
    target_group_arn   = "arn:aws:elasticloadbalancing:ap-southeast-1:123456789012:targetgroup/zeus-proteus-tg-prod/9a03c32569881900"
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
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-prod-kronos-vue:latest"
    target_group_arn   = "arn:aws:elasticloadbalancing:ap-southeast-1:123456789012:targetgroup/zeus-kronos-tg-prod/02f7bff07318fa1c"
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
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-prod-morpheus-vue:latest"
    target_group_arn   = "arn:aws:elasticloadbalancing:ap-southeast-1:123456789012:targetgroup/zeus-morpheus-tg-prod/de7d2e572a17e2d3"
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
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-prod-hades-vue:latest"
    target_group_arn   = "arn:aws:elasticloadbalancing:ap-southeast-1:123456789012:targetgroup/zeus-hades-tg-prod/77d284ccd80715ac"
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
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-prod-hephaestus-vue:latest"
    target_group_arn   = "arn:aws:elasticloadbalancing:ap-southeast-1:123456789012:targetgroup/zeus-hephaestus-tg-prod/5de7e1215ef48761"
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
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-prod-poseidon-vue:latest"
    target_group_arn   = "arn:aws:elasticloadbalancing:ap-southeast-1:123456789012:targetgroup/zeus-poseidon-tg-prod/5c7f4e0382f66253"
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
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-prod-ares-admin-vue:latest"
    target_group_arn   = "arn:aws:elasticloadbalancing:ap-southeast-1:123456789012:targetgroup/zeus-ares-admin-tg-prod/3735488adc481f0f"
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
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-prod-triton-vue:latest"
    target_group_arn   = "arn:aws:elasticloadbalancing:ap-southeast-1:123456789012:targetgroup/zeus-triton-tg-prod/548eacb169215a0c"
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
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-prod-arachne-client-vue:latest"
    target_group_arn   = "arn:aws:elasticloadbalancing:ap-southeast-1:123456789012:targetgroup/zeus-arachne-client-tg-prod/7e999ac6273e8feb"
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
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-prod-hermes-vue:latest"
    target_group_arn   = "arn:aws:elasticloadbalancing:ap-southeast-1:123456789012:targetgroup/zeus-hermes-tg-prod/e3bde9dfb0b0265b"
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
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-prod-orion-vue:latest"
    target_group_arn   = "arn:aws:elasticloadbalancing:ap-southeast-1:123456789012:targetgroup/zeus-orion-tg-prod/5a1ca03320bc95d1"
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
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-prod-ares-client-vue:latest"
    target_group_arn   = "arn:aws:elasticloadbalancing:ap-southeast-1:123456789012:targetgroup/zeus-ares-client-tg-prod/db19c7a490b1c2a3"
  }
}