environment               = "prod"
cluster_name              = "moirai"
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
  "microservice-scheduler" = {
    launch_type        = "EC2"
    provider           = "EC2_DYNAMIC"
    capacity_provider  = ""
    cpu                = 512
    memory             = 2048
    memory_reservation = 2048
    count              = 0
    port               = 8406

    # Standardized Image Path
    image            = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-prod-microservice-scheduler:latest"
    host_volume_name = ""
    host_volume_path = ""
    target_group_arn = ["arn:aws:elasticloadbalancing:ap-southeast-1:123456789012:targetgroup/scheduler-tg-prod/59cdf1f754d10f09"]

    # Scaling & Placement Defaults
    max_capacity       = 4
    cpu_target_value   = 75.0
    scale_out_cooldown = 180
    scale_in_cooldown  = 180
    cp_weight          = 100

    env_vars = {
      "SPRING_APPLICATION_NAME"                   = "scheduler-restapi"
      "SPRING_PROFILES_ACTIVE"                    = "plat-prod"
      "SERVER_PORT"                               = "8406"
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