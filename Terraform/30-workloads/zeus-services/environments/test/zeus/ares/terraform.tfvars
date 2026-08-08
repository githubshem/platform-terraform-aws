# ==========================================
# CORE NETWORKING & CLUSTER CONFIGURATION
# ==========================================
environment        = "test"
cluster_name       = "ares"
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

microservices = {
  "ares-config" = {
    launch_type        = "EC2"
    provider           = "EC2_DYNAMIC"
    cpu                = 128
    memory             = 4096
    memory_reservation = 4096
    count              = 0
    port               = 9104
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-test-ares-config:latest"
    host_volume_name   = ""
    host_volume_path   = ""
    target_group_arn   = []
    max_capacity       = 4
    cpu_target_value   = 75.0
    scale_out_cooldown = 180
    scale_in_cooldown  = 180
    cp_weight          = 100
    env_vars = {
      "SPRING_APPLICATION_NAME"                               = "ares-config"
      "SPRING_PROFILES_ACTIVE"                                = "plat-test"
      "SERVER_PORT"                                           = "9104"
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
  "ares-signing" = {
    launch_type        = "EC2"
    provider           = "EC2_DYNAMIC"
    cpu                = 512
    memory             = 12288
    memory_reservation = 12288
    count              = 0
    port               = 9105
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-test-ares-signing:latest"
    host_volume_name   = ""
    host_volume_path   = ""
    target_group_arn   = []
    max_capacity       = 12
    cpu_target_value   = 75.0
    scale_out_cooldown = 180
    scale_in_cooldown  = 180
    cp_weight          = 100
    env_vars = {
      "SPRING_APPLICATION_NAME"                               = "ares-signing"
      "SPRING_PROFILES_ACTIVE"                                = "plat-test"
      "SERVER_PORT"                                           = "9105"
      "EUREKA_INSTANCE_INSTANCE_ID"                           = "$${spring.cloud.client.ip-address}:$${server.port}"
      "EUREKA_INSTANCE_PREFER_IP_ADDRESS"                     = "true"
      "SPRING_CLOUD_INETUTILS_USE_ONLY_SITE_LOCAL_INTERFACES" = "true"
      "EUREKA_CLIENT_REGISTER_WITH_EUREKA"                    = "true"
      "EUREKA_CLIENT_FETCH_REGISTRY"                          = "true"
      "EUREKA_CLIENT_SERVICEURL_DEFAULTZONE"                  = "http://eureka-svc.test:8901/eureka/"
      "HEALTHCHECK"                                           = "true"
      "JAVA_OPTS"                                             = "-Djava.awt.headless=true -Dsun.net.inetaddr.ttl=5 -Dsun.net.inetaddr.negative.ttl=3"
      "JVM_OPTS"                                              = "-Xms10240m -Xmx10240m -XX:+UseG1GC -XX:+ExitOnOutOfMemoryError"
    }
  },
  "ares-template" = {
    launch_type        = "EC2"
    provider           = "EC2_DYNAMIC"
    cpu                = 128
    memory             = 4096
    memory_reservation = 4096
    count              = 0
    port               = 9106
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-test-ares-template:latest"
    host_volume_name   = ""
    host_volume_path   = ""
    target_group_arn   = []
    max_capacity       = 4
    cpu_target_value   = 75.0
    scale_out_cooldown = 180
    scale_in_cooldown  = 180
    cp_weight          = 100
    env_vars = {
      "SPRING_APPLICATION_NAME"                               = "ares-template"
      "SPRING_PROFILES_ACTIVE"                                = "plat-test"
      "SERVER_PORT"                                           = "9106"
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
  "gateway-ares" = {
    launch_type        = "EC2"
    provider           = "EC2_DYNAMIC"
    cpu                = 128
    memory             = 4096
    memory_reservation = 4096
    count              = 0
    port               = 9107
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-test-gateway-ares:latest"
    host_volume_name   = ""
    host_volume_path   = ""
    target_group_arn   = ["arn:aws:elasticloadbalancing:ap-southeast-1:123456789012:targetgroup/gateway-ares-tg-test/cdf77a30516112f7"]
    max_capacity       = 4
    cpu_target_value   = 75.0
    scale_out_cooldown = 180
    scale_in_cooldown  = 180
    cp_weight          = 100
    env_vars = {
      "SPRING_APPLICATION_NAME"                               = "gateway-ares"
      "SPRING_PROFILES_ACTIVE"                                = "plat-test"
      "SERVER_PORT"                                           = "9107"
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
  "ares-metadata" = {
    launch_type        = "EC2"
    provider           = "EC2_DYNAMIC"
    cpu                = 128
    memory             = 4096
    memory_reservation = 4096
    count              = 0
    port               = 9108
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-test-ares-metadata:latest"
    host_volume_name   = ""
    host_volume_path   = ""
    target_group_arn   = []
    max_capacity       = 4
    cpu_target_value   = 75.0
    scale_out_cooldown = 180
    scale_in_cooldown  = 180
    cp_weight          = 100
    env_vars = {
      "SPRING_APPLICATION_NAME"                               = "ares-metadata"
      "SPRING_PROFILES_ACTIVE"                                = "plat-test"
      "SERVER_PORT"                                           = "9108"
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
  "openapi-ares" = {
    launch_type        = "EC2"
    provider           = "EC2_DYNAMIC"
    cpu                = 512
    memory             = 4096
    memory_reservation = 4096
    count              = 0
    port               = 9109
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-test-openapi-ares:latest"
    host_volume_name   = ""
    host_volume_path   = ""
    target_group_arn   = ["arn:aws:elasticloadbalancing:ap-southeast-1:123456789012:targetgroup/openapi-ares-tg-test/342d2b4f3ed93290", "arn:aws:elasticloadbalancing:ap-southeast-1:123456789012:targetgroup/openapi-ares-test-tg/3924e34e8f2de7f2"]
    max_capacity       = 4
    cpu_target_value   = 75.0
    scale_out_cooldown = 180
    scale_in_cooldown  = 180
    cp_weight          = 100
    env_vars = {
      "SPRING_APPLICATION_NAME"                               = "openapi-ares"
      "SPRING_PROFILES_ACTIVE"                                = "plat-test"
      "SERVER_PORT"                                           = "9109"
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