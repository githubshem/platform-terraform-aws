# ==========================================
# CORE NETWORKING & CLUSTER CONFIGURATION
# ==========================================
environment        = "prod"
cluster_name       = "zeus"
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
  "zeus-notice" = {
    launch_type        = "EC2"
    provider           = "EC2_DYNAMIC"
    cpu                = 128
    memory             = 4096
    memory_reservation = 4096
    count              = 0
    port               = 9110
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-prod-zeus-notice:latest"
    host_volume_name   = ""
    host_volume_path   = ""
    target_group_arn   = []
    max_capacity       = 4
    cpu_target_value   = 75.0
    scale_out_cooldown = 180
    scale_in_cooldown  = 180
    cp_weight          = 100
    env_vars = {
      "SPRING_APPLICATION_NAME"                               = "zeus-notice"
      "SPRING_PROFILES_ACTIVE"                                = "plat-prod"
      "SERVER_PORT"                                           = "9110"
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
  "zeus-config" = {
    launch_type        = "EC2"
    provider           = "EC2_DYNAMIC"
    cpu                = 128
    memory             = 4096
    memory_reservation = 4096
    count              = 0
    port               = 9111
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-prod-zeus-config:latest"
    host_volume_name   = ""
    host_volume_path   = ""
    target_group_arn   = []
    max_capacity       = 4
    cpu_target_value   = 75.0
    scale_out_cooldown = 180
    scale_in_cooldown  = 180
    cp_weight          = 100
    env_vars = {
      "SPRING_APPLICATION_NAME"                               = "zeus-config"
      "SPRING_PROFILES_ACTIVE"                                = "plat-prod"
      "SERVER_PORT"                                           = "9111"
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
  "zeus-promo" = {
    launch_type        = "EC2"
    provider           = "EC2_DYNAMIC"
    cpu                = 128
    memory             = 4096
    memory_reservation = 4096
    count              = 0
    port               = 9112
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-prod-zeus-promo:latest"
    host_volume_name   = ""
    host_volume_path   = ""
    target_group_arn   = []
    max_capacity       = 4
    cpu_target_value   = 75.0
    scale_out_cooldown = 180
    scale_in_cooldown  = 180
    cp_weight          = 100
    env_vars = {
      "SPRING_APPLICATION_NAME"                               = "zeus-promo"
      "SPRING_PROFILES_ACTIVE"                                = "plat-prod"
      "SERVER_PORT"                                           = "9112"
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
  "zeus-customer" = {
    launch_type        = "EC2"
    provider           = "EC2_DYNAMIC"
    cpu                = 128
    memory             = 4096
    memory_reservation = 4096
    count              = 0
    port               = 9113
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-prod-zeus-customer:latest"
    host_volume_name   = ""
    host_volume_path   = ""
    target_group_arn   = []
    max_capacity       = 6
    cpu_target_value   = 75.0
    scale_out_cooldown = 180
    scale_in_cooldown  = 180
    cp_weight          = 100
    env_vars = {
      "SPRING_APPLICATION_NAME"                               = "zeus-customer"
      "SPRING_PROFILES_ACTIVE"                                = "plat-prod"
      "SERVER_PORT"                                           = "9113"
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
  "zeus-workflow" = {
    launch_type        = "EC2"
    provider           = "EC2_DYNAMIC"
    cpu                = 128
    memory             = 4096
    memory_reservation = 4096
    count              = 0
    port               = 9114
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-prod-zeus-workflow:latest"
    host_volume_name   = ""
    host_volume_path   = ""
    target_group_arn   = []
    max_capacity       = 6
    cpu_target_value   = 75.0
    scale_out_cooldown = 180
    scale_in_cooldown  = 180
    cp_weight          = 100
    env_vars = {
      "SPRING_APPLICATION_NAME"                               = "zeus-workflow"
      "SPRING_PROFILES_ACTIVE"                                = "plat-prod"
      "SERVER_PORT"                                           = "9114"
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
  "zeus-metric" = {
    launch_type        = "EC2"
    provider           = "EC2_DYNAMIC"
    cpu                = 512
    memory             = 4096
    memory_reservation = 4096
    count              = 0
    port               = 9115
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-prod-zeus-metric:latest"
    host_volume_name   = ""
    host_volume_path   = ""
    target_group_arn   = []
    max_capacity       = 8
    cpu_target_value   = 75.0
    scale_out_cooldown = 180
    scale_in_cooldown  = 180
    cp_weight          = 100
    env_vars = {
      "SPRING_APPLICATION_NAME"                               = "zeus-metric"
      "SPRING_PROFILES_ACTIVE"                                = "plat-prod"
      "SERVER_PORT"                                           = "9115"
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
  "gateway-zeus" = {
    launch_type        = "EC2"
    provider           = "EC2_DYNAMIC"
    cpu                = 128
    memory             = 4096
    memory_reservation = 4096
    count              = 0
    port               = 9116
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-prod-gateway-zeus:latest"
    host_volume_name   = ""
    host_volume_path   = ""
    target_group_arn   = ["arn:aws:elasticloadbalancing:ap-southeast-1:123456789012:targetgroup/gateway-zeus-tg-prod/1f685ddf7a8cb072"]
    max_capacity       = 6
    cpu_target_value   = 75.0
    scale_out_cooldown = 180
    scale_in_cooldown  = 180
    cp_weight          = 100
    env_vars = {
      "SPRING_APPLICATION_NAME"                               = "gateway-zeus"
      "SPRING_PROFILES_ACTIVE"                                = "plat-prod"
      "SERVER_PORT"                                           = "9116"
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
  "openapi-zeus" = {
    launch_type        = "EC2"
    provider           = "EC2_DYNAMIC"
    cpu                = 128
    memory             = 4096
    memory_reservation = 4096
    count              = 0
    port               = 9117
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-prod-openapi-zeus:latest"
    host_volume_name   = ""
    host_volume_path   = ""
    target_group_arn   = ["arn:aws:elasticloadbalancing:ap-southeast-1:123456789012:targetgroup/openapi-zeus-tg-prod/497211fc5a6a9d6f"]
    max_capacity       = 4
    cpu_target_value   = 75.0
    scale_out_cooldown = 180
    scale_in_cooldown  = 180
    cp_weight          = 100
    env_vars = {
      "SPRING_APPLICATION_NAME"                               = "openapi-zeus"
      "SPRING_PROFILES_ACTIVE"                                = "plat-prod"
      "SERVER_PORT"                                           = "9117"
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
  "notus-zeus" = {
    launch_type        = "EC2"
    provider           = "EC2_DYNAMIC"
    cpu                = 128
    memory             = 4096
    memory_reservation = 4096
    count              = 0
    port               = 9118
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-prod-notus-zeus:latest"
    host_volume_name   = ""
    host_volume_path   = ""
    target_group_arn   = ["arn:aws:elasticloadbalancing:ap-southeast-1:123456789012:targetgroup/notus-zeus-tg-prod/550e761e56ce46b3"]
    max_capacity       = 8
    cpu_target_value   = 75.0
    scale_out_cooldown = 180
    scale_in_cooldown  = 180
    cp_weight          = 100
    env_vars = {
      "SPRING_APPLICATION_NAME"                               = "notus-zeus"
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
      "JVM_OPTS"                                              = "-Xms2560m -Xmx2560m -XX:+UseG1GC -XX:+ExitOnOutOfMemoryError"
    }
  }
}