environment               = "prod"
cluster_name              = "atlas"
aws_region                = "ap-southeast-1"
container_insights        = "disabled"
ec2_instance_type         = "r7i.large"
min_size                  = 0
max_size                  = 10
ecs_instance_profile_name = "ecsInstanceRole"
ecs_execution_role_arn    = "arn:aws:iam::123456789012:role/ecsTaskExecutionRole"
ecs_task_role_arn         = "arn:aws:iam::123456789012:role/ecsTaskRole"
target_capacity           = 100
ami_id                    = "ami-0ddd444eee555fff"
default_cp_weight         = 100
cloudwatch_retention_days = 30
placement_strategy_type   = "binpack"
placement_strategy_field  = "memory"
ec2_key_name              = "plat-prod-services"

project_tags = {
  Environment = "prod"
  Project     = "plat-hera-zeus"
  CostCenter  = "ExampleCorp"
  ManagedBy   = "terraform"
}

# ----------------------------------------------------------------------
# MICROSERVICES DEFINITIONS
# ----------------------------------------------------------------------
microservices = {
  "platform-adminapi" = {
    launch_type        = "EC2"
    provider           = "EC2_DYNAMIC"
    capacity_provider  = ""
    cpu                = 512
    memory             = 4096
    memory_reservation = 4096
    count              = 0
    port               = 8802

    # Standardized Image and Volume Paths
    image            = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-prod-platform-adminapi:latest"
    host_volume_name = "awseb-logs-platform-adminapi-prod"
    host_volume_path = "/var/log/containers/platform-adminapi-prod"
    target_group_arn = ["arn:aws:elasticloadbalancing:ap-southeast-1:123456789012:targetgroup/platform-adminapi-tg-prod/b50fead0221d2f82"]

    # Scaling & Placement Defaults
    max_capacity       = 4
    cpu_target_value   = 75.0
    scale_out_cooldown = 180
    scale_in_cooldown  = 180
    cp_weight          = 100

    env_vars = {
      "SPRING_APPLICATION_NAME"                   = "platform-adminapi"
      "SPRING_PROFILES_ACTIVE"                    = "plat-prod"
      "SERVER_PORT"                               = "8802"
      "EUREKA_INSTANCE_INSTANCE_ID"               = "$${spring.cloud.client.ip-address}:$${server.port}"
      "EUREKA_INSTANCE_PREFER_IP_ADDRESS"         = "true"
      "SPRING_CLOUD_INETUTILS_PREFERRED_NETWORKS" = "10.10"
      "EUREKA_CLIENT_REGISTER_WITH_EUREKA"        = "true"
      "EUREKA_CLIENT_FETCH_REGISTRY"              = "true"
      "EUREKA_CLIENT_SERVICEURL_DEFAULTZONE"      = "http://eureka-svc.prod:8901/eureka/"
      "HEALTHCHECK"                               = "true"
      "JAVA_OPTS"                                 = "-Djava.awt.headless=true -Dsun.net.inetaddr.ttl=5 -Dsun.net.inetaddr.negative.ttl=3"
      "JVM_OPTS"                                  = "-Xms2048m -Xmx2048m -XX:+UseG1GC -XX:MaxGCPauseMillis=200 -Xlog:gc*,safepoint:stdout:time,level,tags -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/root/dump_bak -XX:+ExitOnOutOfMemoryError"
    }
  },

  "platform-coreapi" = {
    launch_type        = "EC2"
    provider           = "EC2_DYNAMIC"
    capacity_provider  = ""
    cpu                = 1024
    memory             = 4096
    memory_reservation = 4096
    count              = 0
    port               = 8803

    # Standardized Image and Volume Paths
    image            = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-prod-platform-coreapi:latest"
    host_volume_name = "awseb-logs-platform-coreapi-prod"
    host_volume_path = "/var/log/containers/platform-coreapi-prod"
    target_group_arn = ["arn:aws:elasticloadbalancing:ap-southeast-1:123456789012:targetgroup/platform-coreapi-tg-prod/1bed140e23791be4"]

    # Scaling & Placement Defaults
    max_capacity       = 4
    cpu_target_value   = 75.0
    scale_out_cooldown = 180
    scale_in_cooldown  = 180
    cp_weight          = 100

    env_vars = {
      "SPRING_APPLICATION_NAME"                   = "platform-coreapi"
      "SPRING_PROFILES_ACTIVE"                    = "plat-prod"
      "SERVER_PORT"                               = "8803"
      "EUREKA_INSTANCE_INSTANCE_ID"               = "$${spring.cloud.client.ip-address}:$${server.port}"
      "EUREKA_INSTANCE_PREFER_IP_ADDRESS"         = "true"
      "SPRING_CLOUD_INETUTILS_PREFERRED_NETWORKS" = "10.10"
      "EUREKA_CLIENT_REGISTER_WITH_EUREKA"        = "true"
      "EUREKA_CLIENT_FETCH_REGISTRY"              = "true"
      "EUREKA_CLIENT_SERVICEURL_DEFAULTZONE"      = "http://eureka-svc.prod:8901/eureka/"
      "HEALTHCHECK"                               = "true"
      "JAVA_OPTS"                                 = "-Djava.awt.headless=true -Dsun.net.inetaddr.ttl=5 -Dsun.net.inetaddr.negative.ttl=3"
      "JVM_OPTS"                                  = "-Xms2048m -Xmx2048m -XX:+UseG1GC -XX:MaxGCPauseMillis=200 -Xlog:gc*,safepoint:stdout:time,level,tags -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/root/dump_bak -XX:+ExitOnOutOfMemoryError"
    }
  },

  "platform-openapi" = {
    launch_type        = "EC2"
    provider           = "EC2_DYNAMIC"
    capacity_provider  = ""
    cpu                = 512
    memory             = 4096
    memory_reservation = 4096
    count              = 0
    port               = 8801

    # Standardized Image and Volume Paths
    image            = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-prod-platform-openapi:latest"
    host_volume_name = "awseb-logs-platform-openapi-prod"
    host_volume_path = "/var/log/containers/platform-openapi-prod"
    target_group_arn = ["arn:aws:elasticloadbalancing:ap-southeast-1:123456789012:targetgroup/platform-openapi-tg-prod/ecb87b90a2746a9f"]

    # Scaling & Placement Defaults
    max_capacity       = 4
    cpu_target_value   = 75.0
    scale_out_cooldown = 180
    scale_in_cooldown  = 180
    cp_weight          = 100

    env_vars = {
      "SPRING_APPLICATION_NAME"                   = "platform-openapi"
      "SPRING_PROFILES_ACTIVE"                    = "plat-prod"
      "SERVER_PORT"                               = "8801"
      "EUREKA_INSTANCE_INSTANCE_ID"               = "$${spring.cloud.client.ip-address}:$${server.port}"
      "EUREKA_INSTANCE_PREFER_IP_ADDRESS"         = "true"
      "SPRING_CLOUD_INETUTILS_PREFERRED_NETWORKS" = "10.10"
      "EUREKA_CLIENT_REGISTER_WITH_EUREKA"        = "true"
      "EUREKA_CLIENT_FETCH_REGISTRY"              = "true"
      "EUREKA_CLIENT_SERVICEURL_DEFAULTZONE"      = "http://eureka-svc.prod:8901/eureka/"
      "HEALTHCHECK"                               = "true"
      "JAVA_OPTS"                                 = "-Djava.awt.headless=true -Dsun.net.inetaddr.ttl=5 -Dsun.net.inetaddr.negative.ttl=3"
      "JVM_OPTS"                                  = "-Xms2048m -Xmx2048m -XX:+UseG1GC -XX:MaxGCPauseMillis=200 -Xlog:gc*,safepoint:stdout:time,level,tags -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/root/dump_bak -XX:+ExitOnOutOfMemoryError"
    }
  }
}
