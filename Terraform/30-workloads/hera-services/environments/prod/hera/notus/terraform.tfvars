environment               = "prod"
cluster_name              = "notus"
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
  "microservice-notus" = {
    launch_type        = "EC2"
    provider           = "EC2_DYNAMIC"
    cpu                = 1024
    memory             = 8192
    memory_reservation = 8192
    count              = 0
    port               = 8407

    # Standardized Image and Volume Paths
    image            = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-prod-microservice-notus:latest"
    host_volume_name = "awseb-logs-microservice-notus-prod"
    host_volume_path = "/var/log/containers/microservice-notus-prod"
    target_group_arn = ["arn:aws:elasticloadbalancing:ap-southeast-1:123456789012:targetgroup/microservice-notus-tg-prod/60e323b2797e3cb1", "arn:aws:elasticloadbalancing:ap-southeast-1:123456789012:targetgroup/microsvc-notus-tg-pub-prod/0567befc634fee50"]

    # Scaling & Placement Defaults
    max_capacity       = 4
    cpu_target_value   = 75.0
    scale_out_cooldown = 180
    scale_in_cooldown  = 180
    cp_weight          = 100

    env_vars = {
      "SPRING_APPLICATION_NAME"                   = "notus-restapi"
      "SPRING_PROFILES_ACTIVE"                    = "plat-prod"
      "SERVER_PORT"                               = "8407"
      "EUREKA_INSTANCE_INSTANCE_ID"               = "$${spring.cloud.client.ip-address}:$${server.port}"
      "EUREKA_INSTANCE_PREFER_IP_ADDRESS"         = "true"
      "SPRING_CLOUD_INETUTILS_PREFERRED_NETWORKS" = "10.10"
      "EUREKA_CLIENT_REGISTER_WITH_EUREKA"        = "true"
      "EUREKA_CLIENT_FETCH_REGISTRY"              = "true"
      "EUREKA_CLIENT_SERVICEURL_DEFAULTZONE"      = "http://eureka-svc.prod:8901/eureka/"
      "HEALTHCHECK"                               = "true"
      "JAVA_OPTS"                                 = "-Djava.awt.headless=true -Dsun.net.inetaddr.ttl=5 -Dsun.net.inetaddr.negative.ttl=3"
      "JVM_OPTS"                                  = "-Xms4096m -Xmx4096m -XX:+UseG1GC -XX:MaxGCPauseMillis=200 -Xlog:gc*,safepoint:stdout:time,level,tags -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/root/dump_bak -XX:+ExitOnOutOfMemoryError"
    }
  },

  "boreas-notus" = {
    launch_type        = "EC2"
    provider           = "EC2_DYNAMIC"
    cpu                = 512
    memory             = 2048
    memory_reservation = 2048
    count              = 0
    port               = 8407

    # Standardized Image and Volume Paths
    image            = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-prod-boreas-notus:latest"
    host_volume_name = "awseb-logs-boreas-notus-prod"
    host_volume_path = "/var/log/containers/boreas-notus-prod"
    target_group_arn = []

    # Scaling & Placement Defaults
    max_capacity       = 4
    cpu_target_value   = 75.0
    scale_out_cooldown = 180
    scale_in_cooldown  = 180
    cp_weight          = 100

    env_vars = {
      "SPRING_APPLICATION_NAME"                   = "boreas-notus"
      "SPRING_PROFILES_ACTIVE"                    = "plat-prod"
      "SERVER_PORT"                               = "8407"
      "EUREKA_INSTANCE_INSTANCE_ID"               = "$${spring.cloud.client.ip-address}:$${server.port}"
      "EUREKA_INSTANCE_PREFER_IP_ADDRESS"         = "true"
      "SPRING_CLOUD_INETUTILS_PREFERRED_NETWORKS" = "10.10"
      "EUREKA_CLIENT_REGISTER_WITH_EUREKA"        = "true"
      "EUREKA_CLIENT_FETCH_REGISTRY"              = "true"
      "EUREKA_CLIENT_SERVICEURL_DEFAULTZONE"      = "http://eureka-svc.prod:8901/eureka/"
      "HEALTHCHECK"                               = "true"
      "JAVA_OPTS"                                 = "-Djava.awt.headless=true -Dsun.net.inetaddr.ttl=5 -Dsun.net.inetaddr.negative.ttl=3"
      "JVM_OPTS"                                  = "-Xms1024m -Xmx1024m -XX:+UseG1GC -XX:MaxGCPauseMillis=200 -Xlog:gc*,safepoint:stdout:time,level,tags -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/root/dump_bak -XX:+ExitOnOutOfMemoryError"
    }
  }
}