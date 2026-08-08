environment               = "prod"
cluster_name              = "plutus"
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
  "microservice-billing" = {
    launch_type        = "EC2"
    provider           = "EC2_DYNAMIC"
    cpu                = 1024
    memory             = 4096
    memory_reservation = 4096
    count              = 0
    port               = 8309

    # Standardized Image and Volume Paths (Removed -test)
    image            = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-prod-microservice-billing:latest"
    host_volume_name = "awseb-logs-microservice-billing-prod"
    host_volume_path = "/var/log/containers/microservice-billing-prod"
    target_group_arn = []

    # Scaling & Placement Defaults
    max_capacity       = 4
    cpu_target_value   = 75.0
    scale_out_cooldown = 180
    scale_in_cooldown  = 180
    cp_weight          = 100

    env_vars = {
      "SPRING_APPLICATION_NAME"                   = "payment-restapi"
      "SPRING_PROFILES_ACTIVE"                    = "plat-prod"
      "SERVER_PORT"                               = "8309"
      "EUREKA_INSTANCE_INSTANCE_ID"               = "$${spring.cloud.client.ip-address}:$${server.port}"
      "EUREKA_INSTANCE_PREFER_IP_ADDRESS"         = "true"
      "SPRING_CLOUD_INETUTILS_PREFERRED_NETWORKS" = "10.10"
      "EUREKA_CLIENT_REGISTER_WITH_EUREKA"        = "true"
      "EUREKA_CLIENT_FETCH_REGISTRY"              = "true"
      "EUREKA_CLIENT_SERVICEURL_DEFAULTZONE"      = "http://eureka-svc.prod:8901/eureka/"
      "HEALTHCHECK"                               = "true"
      "JAVA_OPTS"                                 = "-Djava.awt.headless=true -Dsun.net.inetaddr.ttl=5 -Dsun.net.inetaddr.negative.ttl=3"
      "JVM_OPTS"                                  = "-Xms2048m -Xmx2048m -XX:+UseG1GC -XX:MaxGCPauseMillis=200 -Xlog:gc*,safepoint:stdout:time,level,tags -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/tmp -XX:+ExitOnOutOfMemoryError"
    }
  }
}