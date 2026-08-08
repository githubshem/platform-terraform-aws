# ==========================================
# CORE NETWORKING & CLUSTER CONFIGURATION
# ==========================================
environment        = "prod"
cluster_name       = "artemis"
ami_id             = "ami-0ddd444eee555fff"
aws_region         = "ap-southeast-1"
container_insights = "disabled"
ec2_instance_type  = "r7i.large"
min_size           = 0
max_size           = 10
ec2_key_name       = "plat-prod-services"

# IAM & SCALING
ecs_instance_profile_name = "ecsInstanceRole"
ecs_execution_role_arn    = "arn:aws:iam::123456789012:role/ecsTaskExecutionRole"
ecs_task_role_arn         = "arn:aws:iam::123456789012:role/ecsTaskRole"
target_capacity           = 100
default_cp_weight         = 100
cloudwatch_retention_days = 30
placement_strategy_type   = "binpack"
placement_strategy_field  = "memory"
az_rebalancing            = "DISABLED"

project_tags = {
  Environment = "prod"
  Project     = "plat-zeus-backend"
  CostCenter  = "ExampleCorp"
  ManagedBy   = "terraform"
}

# ----------------------------------------------------------------------
# MICROSERVICES DEFINITIONS
# ----------------------------------------------------------------------
microservices = {
  "artemis-notice" = {
    launch_type        = "EC2"
    provider           = "EC2_DYNAMIC"
    cpu                = 128
    memory             = 12288
    memory_reservation = 12288
    count              = 0
    port               = 9118
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-prod-artemis-notice:latest"
    host_volume_name   = ""
    host_volume_path   = ""
    target_group_arn   = ["arn:aws:elasticloadbalancing:ap-southeast-1:123456789012:targetgroup/plat-prod-artemis-notice/6d4519d4f8c48e70"]
    max_capacity       = 4
    cpu_target_value   = 75.0
    scale_out_cooldown = 180
    scale_in_cooldown  = 180
    cp_weight          = 100
    env_vars = {
      "SPRING_APPLICATION_NAME"                               = "artemis-notice"
      "SPRING_PROFILES_ACTIVE"                                = "plat-prod"
      "SERVER_PORT"                                           = "9118"
      "EUREKA_INSTANCE_INSTANCE_ID"                           = "$${spring.cloud.client.ip-address}:$${server.port}"
      "EUREKA_INSTANCE_PREFER_IP_ADDRESS"                     = "true"
      "SPRING_CLOUD_INETUTILS_USE_ONLY_SITE_LOCAL_INTERFACES" = "true"
      "EUREKA_CLIENT_REGISTER_WITH_EUREKA"                    = "true"
      "EUREKA_CLIENT_FETCH_REGISTRY"                          = "true"
      "EUREKA_CLIENT_SERVICEURL_DEFAULTZONE"                  = "http://eureka-svc.prod:8901/eureka/"
      "HEALTHCHECK"                                           = "true"
      "JAVA_OPTS"                                             = "-Djava.awt.headless=true -Dsun.net.inetaddr.ttl=5 -Dsun.net.inetaddr.negative.ttl=3"
      "JVM_OPTS"                                              = "-Xms10240m -Xmx10240m -XX:+UseG1GC -XX:+ExitOnOutOfMemoryError"
    }
  },
  "artemis-config" = {
    launch_type        = "EC2"
    provider           = "EC2_DYNAMIC"
    cpu                = 128
    memory             = 4096
    memory_reservation = 4096
    count              = 0
    port               = 9119
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-prod-artemis-config:latest"
    host_volume_name   = ""
    host_volume_path   = ""
    target_group_arn   = []
    max_capacity       = 4
    cpu_target_value   = 75.0
    scale_out_cooldown = 180
    scale_in_cooldown  = 180
    cp_weight          = 100
    env_vars = {
      "SPRING_APPLICATION_NAME"                               = "artemis-config"
      "SPRING_PROFILES_ACTIVE"                                = "plat-prod"
      "SERVER_PORT"                                           = "9119"
      "EUREKA_INSTANCE_INSTANCE_ID"                           = "$${spring.cloud.client.ip-address}:$${server.port}"
      "EUREKA_INSTANCE_PREFER_IP_ADDRESS"                     = "true"
      "SPRING_CLOUD_INETUTILS_USE_ONLY_SITE_LOCAL_INTERFACES" = "true"
      "EUREKA_CLIENT_REGISTER_WITH_EUREKA"                    = "true"
      "EUREKA_CLIENT_FETCH_REGISTRY"                          = "true"
      "EUREKA_CLIENT_SERVICEURL_DEFAULTZONE"                  = "http://eureka-svc.prod:8901/eureka/"
      "HEALTHCHECK"                                           = "true"
      "JAVA_OPTS"                                             = "-Djava.awt.headless=true -Dsun.net.inetaddr.ttl=5 -Dsun.net.inetaddr.negative.ttl=3"
      "JVM_OPTS"                                              = "-Xms2560m -Xmx2560m -XX:+UseG1GC -XX:+ExitOnOutOfMemoryError"
    }
  },
  "artemis-monitor" = {
    launch_type        = "EC2"
    provider           = "EC2_DYNAMIC"
    cpu                = 128
    memory             = 4096
    memory_reservation = 4096
    count              = 0
    port               = 9120
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-prod-artemis-monitor:latest"
    host_volume_name   = ""
    host_volume_path   = ""
    target_group_arn   = ["arn:aws:elasticloadbalancing:ap-southeast-1:123456789012:targetgroup/artemis-monitor-tg-prod/3f452a7346851475"]
    max_capacity       = 4
    cpu_target_value   = 75.0
    scale_out_cooldown = 180
    scale_in_cooldown  = 180
    cp_weight          = 100
    env_vars = {
      "SPRING_APPLICATION_NAME"                               = "artemis-monitor"
      "SPRING_PROFILES_ACTIVE"                                = "plat-prod"
      "SERVER_PORT"                                           = "9120"
      "EUREKA_INSTANCE_INSTANCE_ID"                           = "$${spring.cloud.client.ip-address}:$${server.port}"
      "EUREKA_INSTANCE_PREFER_IP_ADDRESS"                     = "true"
      "SPRING_CLOUD_INETUTILS_USE_ONLY_SITE_LOCAL_INTERFACES" = "true"
      "EUREKA_CLIENT_REGISTER_WITH_EUREKA"                    = "true"
      "EUREKA_CLIENT_FETCH_REGISTRY"                          = "true"
      "EUREKA_CLIENT_SERVICEURL_DEFAULTZONE"                  = "http://eureka-svc.prod:8901/eureka/"
      "HEALTHCHECK"                                           = "true"
      "JAVA_OPTS"                                             = "-Djava.awt.headless=true -Dsun.net.inetaddr.ttl=5 -Dsun.net.inetaddr.negative.ttl=3"
      "JVM_OPTS"                                              = "-Xms2560m -Xmx2560m -XX:+UseG1GC -XX:+ExitOnOutOfMemoryError"
    }
  },
  "openapi-artemis" = {
    launch_type        = "EC2"
    provider           = "EC2_DYNAMIC"
    cpu                = 512
    memory             = 12288
    memory_reservation = 12288
    count              = 0
    port               = 9122
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-prod-openapi-artemis:latest"
    host_volume_name   = ""
    host_volume_path   = ""
    target_group_arn   = ["arn:aws:elasticloadbalancing:ap-southeast-1:123456789012:targetgroup/openapi-artemis-tg-prod/ae6f9c70ff88a6cc"]
    max_capacity       = 8
    cpu_target_value   = 75.0
    scale_out_cooldown = 180
    scale_in_cooldown  = 180
    cp_weight          = 100
    env_vars = {
      "SPRING_APPLICATION_NAME"                               = "openapi-artemis"
      "SPRING_PROFILES_ACTIVE"                                = "plat-prod"
      "SERVER_PORT"                                           = "9122"
      "EUREKA_INSTANCE_INSTANCE_ID"                           = "$${spring.cloud.client.ip-address}:$${server.port}"
      "EUREKA_INSTANCE_PREFER_IP_ADDRESS"                     = "true"
      "SPRING_CLOUD_INETUTILS_USE_ONLY_SITE_LOCAL_INTERFACES" = "true"
      "EUREKA_CLIENT_REGISTER_WITH_EUREKA"                    = "true"
      "EUREKA_CLIENT_FETCH_REGISTRY"                          = "true"
      "EUREKA_CLIENT_SERVICEURL_DEFAULTZONE"                  = "http://eureka-svc.prod:8901/eureka/"
      "HEALTHCHECK"                                           = "true"
      "JAVA_OPTS"                                             = "-Djava.awt.headless=true -Dsun.net.inetaddr.ttl=5 -Dsun.net.inetaddr.negative.ttl=3"
      "JVM_OPTS"                                              = "-Xms10240m -Xmx10240m -XX:+UseG1GC -XX:+ExitOnOutOfMemoryError"
    }
  }
}