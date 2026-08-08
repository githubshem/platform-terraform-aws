# ==========================================
# CORE NETWORKING & CLUSTER CONFIGURATION
# ==========================================
environment        = "test"
cluster_name       = "hestia"
ami_id             = "ami-0ddd444eee555fff"
aws_region         = "ap-southeast-1"
container_insights = "disabled"
ec2_instance_type  = "r7i.large"
min_size           = 0
max_size           = 10
ec2_key_name       = "plat-test-services"

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
  Environment = "test"
  Project     = "plat-zeus-backend"
  CostCenter  = "ExampleCorp"
  ManagedBy   = "terraform"
}

# ----------------------------------------------------------------------
# MICROSERVICES DEFINITIONS
# ----------------------------------------------------------------------
microservices = {
  "hestia-algorithm" = {
    launch_type        = "EC2"
    provider           = "EC2_DYNAMIC"
    cpu                = 128
    memory             = 4096
    memory_reservation = 4096
    count              = 0
    port               = 9123
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-test-hestia-algorithm:latest"
    host_volume_name   = ""
    host_volume_path   = ""
    target_group_arn   = []
    max_capacity       = 4
    cpu_target_value   = 75.0
    scale_out_cooldown = 180
    scale_in_cooldown  = 180
    cp_weight          = 100
    env_vars = {
      "SPRING_APPLICATION_NAME"                               = "hestia-algorithm"
      "SPRING_PROFILES_ACTIVE"                                = "plat-test"
      "SERVER_PORT"                                           = "9123"
      "EUREKA_INSTANCE_INSTANCE_ID"                           = "$${spring.cloud.client.ip-address}:$${server.port}"
      "EUREKA_INSTANCE_PREFER_IP_ADDRESS"                     = "true"
      "SPRING_CLOUD_INETUTILS_USE_ONLY_SITE_LOCAL_INTERFACES" = "true"
      "EUREKA_CLIENT_REGISTER_WITH_EUREKA"                    = "true"
      "EUREKA_CLIENT_FETCH_REGISTRY"                          = "true"
      "EUREKA_CLIENT_SERVICEURL_DEFAULTZONE"                  = "http://eureka-svc.test:8901/eureka/"
      "HEALTHCHECK"                                           = "true"
      "JAVA_OPTS"                                             = "-Djava.awt.headless=true -Dsun.net.inetaddr.ttl=5 -Dsun.net.inetaddr.negative.ttl=3"
      "JVM_OPTS"                                              = "-Xms2560m -Xmx2560m -XX:+UseG1GC -XX:+ExitOnOutOfMemoryError"
    }
  },
  "hestia-config" = {
    launch_type        = "EC2"
    provider           = "EC2_DYNAMIC"
    cpu                = 128
    memory             = 4096
    memory_reservation = 4096
    count              = 0
    port               = 9124
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-test-hestia-config:latest"
    host_volume_name   = ""
    host_volume_path   = ""
    target_group_arn   = []
    max_capacity       = 4
    cpu_target_value   = 75.0
    scale_out_cooldown = 180
    scale_in_cooldown  = 180
    cp_weight          = 100
    env_vars = {
      "SPRING_APPLICATION_NAME"                               = "hestia-config"
      "SPRING_PROFILES_ACTIVE"                                = "plat-test"
      "SERVER_PORT"                                           = "9124"
      "EUREKA_INSTANCE_INSTANCE_ID"                           = "$${spring.cloud.client.ip-address}:$${server.port}"
      "EUREKA_INSTANCE_PREFER_IP_ADDRESS"                     = "true"
      "SPRING_CLOUD_INETUTILS_USE_ONLY_SITE_LOCAL_INTERFACES" = "true"
      "EUREKA_CLIENT_REGISTER_WITH_EUREKA"                    = "true"
      "EUREKA_CLIENT_FETCH_REGISTRY"                          = "true"
      "EUREKA_CLIENT_SERVICEURL_DEFAULTZONE"                  = "http://eureka-svc.test:8901/eureka/"
      "HEALTHCHECK"                                           = "true"
      "JAVA_OPTS"                                             = "-Djava.awt.headless=true -Dsun.net.inetaddr.ttl=5 -Dsun.net.inetaddr.negative.ttl=3"
      "JVM_OPTS"                                              = "-Xms2560m -Xmx2560m -XX:+UseG1GC -XX:+ExitOnOutOfMemoryError"
    }
  },
  "hestia-scoring" = {
    launch_type        = "EC2"
    provider           = "EC2_DYNAMIC"
    cpu                = 512
    memory             = 6144
    memory_reservation = 6144
    count              = 0
    port               = 9125
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-test-hestia-scoring:latest"
    host_volume_name   = ""
    host_volume_path   = ""
    target_group_arn   = []
    max_capacity       = 6
    cpu_target_value   = 75.0
    scale_out_cooldown = 180
    scale_in_cooldown  = 180
    cp_weight          = 100
    env_vars = {
      "SPRING_APPLICATION_NAME"                               = "hestia-scoring"
      "SPRING_PROFILES_ACTIVE"                                = "plat-test"
      "SERVER_PORT"                                           = "9125"
      "EUREKA_INSTANCE_INSTANCE_ID"                           = "$${spring.cloud.client.ip-address}:$${server.port}"
      "EUREKA_INSTANCE_PREFER_IP_ADDRESS"                     = "true"
      "SPRING_CLOUD_INETUTILS_USE_ONLY_SITE_LOCAL_INTERFACES" = "true"
      "EUREKA_CLIENT_REGISTER_WITH_EUREKA"                    = "true"
      "EUREKA_CLIENT_FETCH_REGISTRY"                          = "true"
      "EUREKA_CLIENT_SERVICEURL_DEFAULTZONE"                  = "http://eureka-svc.test:8901/eureka/"
      "HEALTHCHECK"                                           = "true"
      "JAVA_OPTS"                                             = "-Djava.awt.headless=true -Dsun.net.inetaddr.ttl=5 -Dsun.net.inetaddr.negative.ttl=3"
      "JVM_OPTS"                                              = "-Xms4096m -Xmx4096m -XX:+UseG1GC -XX:+ExitOnOutOfMemoryError"
    }
  },
  "gateway-hestia" = {
    launch_type        = "EC2"
    provider           = "EC2_DYNAMIC"
    cpu                = 128
    memory             = 4096
    memory_reservation = 4096
    count              = 0
    port               = 9126
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-test-gateway-hestia:latest"
    host_volume_name   = ""
    host_volume_path   = ""
    target_group_arn   = ["arn:aws:elasticloadbalancing:ap-southeast-1:123456789012:targetgroup/gateway-hestia-tg-test/b003098eb90108f8"]
    max_capacity       = 4
    cpu_target_value   = 75.0
    scale_out_cooldown = 180
    scale_in_cooldown  = 180
    cp_weight          = 100
    env_vars = {
      "SPRING_APPLICATION_NAME"                               = "gateway-hestia"
      "SPRING_PROFILES_ACTIVE"                                = "plat-test"
      "SERVER_PORT"                                           = "9126"
      "EUREKA_INSTANCE_INSTANCE_ID"                           = "$${spring.cloud.client.ip-address}:$${server.port}"
      "EUREKA_INSTANCE_PREFER_IP_ADDRESS"                     = "true"
      "SPRING_CLOUD_INETUTILS_USE_ONLY_SITE_LOCAL_INTERFACES" = "true"
      "EUREKA_CLIENT_REGISTER_WITH_EUREKA"                    = "true"
      "EUREKA_CLIENT_FETCH_REGISTRY"                          = "true"
      "EUREKA_CLIENT_SERVICEURL_DEFAULTZONE"                  = "http://eureka-svc.test:8901/eureka/"
      "HEALTHCHECK"                                           = "true"
      "JAVA_OPTS"                                             = "-Djava.awt.headless=true -Dsun.net.inetaddr.ttl=5 -Dsun.net.inetaddr.negative.ttl=3"
      "JVM_OPTS"                                              = "-Xms2560m -Xmx2560m -XX:+UseG1GC -XX:+ExitOnOutOfMemoryError"
    }
  },
  "openapi-hestia" = {
    launch_type        = "EC2"
    provider           = "EC2_DYNAMIC"
    cpu                = 128
    memory             = 4096
    memory_reservation = 4096
    count              = 0
    port               = 9127
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-test-openapi-hestia:latest"
    host_volume_name   = ""
    host_volume_path   = ""
    target_group_arn   = ["arn:aws:elasticloadbalancing:ap-southeast-1:123456789012:targetgroup/openapi-hestia-tg-test/578a69bbf6677082", "arn:aws:elasticloadbalancing:ap-southeast-1:123456789012:targetgroup/plat-test-openapi-hestia-pub/d2c06c00885edcfc"]
    max_capacity       = 4
    cpu_target_value   = 75.0
    scale_out_cooldown = 180
    scale_in_cooldown  = 180
    cp_weight          = 100
    env_vars = {
      "SPRING_APPLICATION_NAME"                               = "openapi-hestia"
      "SPRING_PROFILES_ACTIVE"                                = "plat-test"
      "SERVER_PORT"                                           = "9127"
      "EUREKA_INSTANCE_INSTANCE_ID"                           = "$${spring.cloud.client.ip-address}:$${server.port}"
      "EUREKA_INSTANCE_PREFER_IP_ADDRESS"                     = "true"
      "SPRING_CLOUD_INETUTILS_USE_ONLY_SITE_LOCAL_INTERFACES" = "true"
      "EUREKA_CLIENT_REGISTER_WITH_EUREKA"                    = "true"
      "EUREKA_CLIENT_FETCH_REGISTRY"                          = "true"
      "EUREKA_CLIENT_SERVICEURL_DEFAULTZONE"                  = "http://eureka-svc.test:8901/eureka/"
      "HEALTHCHECK"                                           = "true"
      "JAVA_OPTS"                                             = "-Djava.awt.headless=true -Dsun.net.inetaddr.ttl=5 -Dsun.net.inetaddr.negative.ttl=3"
      "JVM_OPTS"                                              = "-Xms2560m -Xmx2560m -XX:+UseG1GC -XX:+ExitOnOutOfMemoryError"
    }
  }
}