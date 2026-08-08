environment               = "test"
cluster_name              = "themis"
ami_id                    = "ami-0ddd444eee555fff"
aws_region                = "ap-southeast-1"
container_insights        = "disabled"
ec2_instance_type         = "r7i.large"
min_size                  = 0
max_size                  = 10
warm_pool_size            = 0
ecs_instance_profile_name = "ecsInstanceRole"
ecs_execution_role_arn    = "arn:aws:iam::123456789012:role/ecsTaskExecutionRole"
ecs_task_role_arn         = "arn:aws:iam::123456789012:role/ecsTaskRole"
target_capacity           = 100
default_cp_weight         = 100
cloudwatch_retention_days = 30
placement_strategy_type   = "binpack"
placement_strategy_field  = "memory"
az_rebalancing            = "DISABLED"
ec2_key_name              = "plat-test-services"

dedicated_capacity_providers = {
  "eureka-dedicated-cp-test" = {
    instance_type = "r7i.large"
    min_size      = 0
    max_size      = 0
  },
  "configserver-dedicated-cp-test" = {
    instance_type = "r7i.large"
    min_size      = 0
    max_size      = 0
  }
}

project_tags = {
  Environment = "test"
  Project     = "plat-hera-zeus"
  CostCenter  = "ExampleCorp"
  ManagedBy   = "terraform"
}

# ----------------------------------------------------------------------
# FRAMEWORK SERVICES DEFINITIONS
# ----------------------------------------------------------------------
microservices = {
  "config-server" = {
    launch_type        = "EC2"
    provider           = "EC2_DYNAMIC"
    capacity_provider  = ""
    cpu                = 512
    memory             = 2048
    memory_reservation = 2048
    count              = 0
    port               = 8902
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-test-config-server:plat-test-20260223132753"
    host_volume_name   = "awseb-logs-plat-test-config-server"
    host_volume_path   = "/var/log/containers/plat-test-config-server"
    target_group_arn   = ["arn:aws:elasticloadbalancing:ap-southeast-1:123456789012:targetgroup/config-tg-test/4eba8e3b208ecb83", "arn:aws:elasticloadbalancing:ap-southeast-1:123456789012:targetgroup/plat-test-config-tg-pub/49a19d15265fd444"]

    # Scaling & Placement Defaults
    max_capacity       = 2
    cpu_target_value   = 75.0
    scale_out_cooldown = 180
    scale_in_cooldown  = 180
    cp_weight          = 100

    env_vars = {
      "SPRING_APPLICATION_NAME"                   = "config-server"
      "SPRING_PROFILES_ACTIVE"                    = "plat-test"
      "SERVER_PORT"                               = "8902"
      "EUREKA_INSTANCE_INSTANCE_ID"               = "$${spring.cloud.client.ip-address}:$${server.port}"
      "EUREKA_INSTANCE_PREFER_IP_ADDRESS"         = "true"
      "SPRING_CLOUD_INETUTILS_PREFERRED_NETWORKS" = "10.10"
      "EUREKA_CLIENT_REGISTER_WITH_EUREKA"        = "true"
      "EUREKA_CLIENT_FETCH_REGISTRY"              = "true"
      "EUREKA_CLIENT_SERVICEURL_DEFAULTZONE"      = "http://eureka-svc.test:8901/eureka/"
      "HEALTHCHECK"                               = "true"
      "MANAGEMENT_ENDPOINT_HEALTH_SHOW_DETAILS"   = "always"
      "JAVA_OPTS"                                 = "-Djava.awt.headless=true -Dsun.net.inetaddr.ttl=15"
      "JVM_OPTS"                                  = "-Xmx1024m -Xms1024m -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/root/dump_bak"
    }
  },

  "eureka-server" = {
    launch_type        = "EC2"
    provider           = "EC2_DYNAMIC"
    capacity_provider  = "eureka-dedicated-cp"
    cpu                = 512
    memory             = 2048
    memory_reservation = 2048
    count              = 0
    port               = 8901
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-test-eureka-server:plat-test-20260223111303"
    host_volume_name   = "awseb-logs-framework-eureka-server"
    host_volume_path   = "/var/log/containers/framework-eureka-server"
    target_group_arn   = ["arn:aws:elasticloadbalancing:ap-southeast-1:123456789012:targetgroup/eureka-tg-test/f4babd4259fe2b21", "arn:aws:elasticloadbalancing:ap-southeast-1:123456789012:targetgroup/plat-test-eureka-tg-pub/b7bceafe78df51e2"]

    max_capacity       = 2
    cpu_target_value   = 75.0
    scale_out_cooldown = 180
    scale_in_cooldown  = 180
    cp_weight          = 100

    env_vars = {
      "SPRING_APPLICATION_NAME"                   = "eureka-server"
      "SPRING_PROFILES_ACTIVE"                    = "plat-test"
      "SERVER_PORT"                               = "8901"
      "EUREKA_INSTANCE_INSTANCE_ID"               = "$${spring.cloud.client.ip-address}:$${server.port}"
      "EUREKA_INSTANCE_PREFER_IP_ADDRESS"         = "true"
      "SPRING_CLOUD_INETUTILS_PREFERRED_NETWORKS" = "10.10"
      "EUREKA_CLIENT_REGISTER_WITH_EUREKA"        = "true"
      "EUREKA_CLIENT_FETCH_REGISTRY"              = "true"
      "EUREKA_CLIENT_SERVICEURL_DEFAULTZONE"      = "http://eureka-svc.test:8901/eureka/"
      "JAVA_OPTS"                                 = "-Djava.awt.headless=true -Dsun.net.inetaddr.ttl=15"
      "JVM_OPTS"                                  = "-Xmx1024m -Xms1024m -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/root/dump_bak"
    }
  },

  "gateway-server" = {
    launch_type        = "EC2"
    provider           = "EC2_DYNAMIC"
    capacity_provider  = ""
    cpu                = 1024
    memory             = 4096
    memory_reservation = 4096
    count              = 0
    port               = 8910
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-dev-gateway-server:latest"
    host_volume_name   = ""
    host_volume_path   = ""
    target_group_arn   = ["arn:aws:elasticloadbalancing:ap-southeast-1:123456789012:targetgroup/gateway-tg-test/5574fbf85c56d026"]

    max_capacity       = 4
    cpu_target_value   = 75.0
    scale_out_cooldown = 180
    scale_in_cooldown  = 180
    cp_weight          = 100

    env_vars = {
      "SPRING_APPLICATION_NAME"                   = "gateway-server"
      "SPRING_PROFILES_ACTIVE"                    = "plat-test"
      "SERVER_PORT"                               = "8910"
      "EUREKA_INSTANCE_INSTANCE_ID"               = "$${spring.cloud.client.ip-address}:$${server.port}"
      "EUREKA_INSTANCE_PREFER_IP_ADDRESS"         = "true"
      "SPRING_CLOUD_INETUTILS_PREFERRED_NETWORKS" = "10.10"
      "EUREKA_CLIENT_REGISTER_WITH_EUREKA"        = "true"
      "EUREKA_CLIENT_FETCH_REGISTRY"              = "true"
      "EUREKA_CLIENT_SERVICEURL_DEFAULTZONE"      = "http://eureka-svc.test:8901/eureka/"
      "HEALTHCHECK"                               = "true"
      "JAVA_OPTS"                                 = "-Djava.awt.headless=true -Dsun.net.inetaddr.ttl=15"
      "JVM_OPTS"                                  = "-Xmx2048m -Xms2048m -XX:MaxPermSize=512m -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/root/dump_bak"
    }
  },

  "framework-compress-server" = {
    launch_type        = "EC2"
    provider           = "EC2_DYNAMIC"
    capacity_provider  = ""
    cpu                = 512
    memory             = 2048
    memory_reservation = 2048
    count              = 0
    port               = 8907
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/framework-compress-server-test:latest"
    host_volume_name   = "awseb-logs-framework-compress-server-test"
    host_volume_path   = "/var/log/containers/framework-compress-server-test"
    target_group_arn   = ["arn:aws:elasticloadbalancing:ap-southeast-1:123456789012:targetgroup/compress-server-tg-test/811b2fbadc3d249c"]

    max_capacity       = 2
    cpu_target_value   = 75.0
    scale_out_cooldown = 180
    scale_in_cooldown  = 180
    cp_weight          = 100

    env_vars = {
      "SPRING_APPLICATION_NAME"                   = "framework-compress-server"
      "SPRING_PROFILES_ACTIVE"                    = "plat-test"
      "SERVER_PORT"                               = "8907"
      "EUREKA_INSTANCE_INSTANCE_ID"               = "$${spring.cloud.client.ip-address}:$${server.port}"
      "EUREKA_INSTANCE_PREFER_IP_ADDRESS"         = "true"
      "SPRING_CLOUD_INETUTILS_PREFERRED_NETWORKS" = "10.10"
      "EUREKA_CLIENT_REGISTER_WITH_EUREKA"        = "true"
      "EUREKA_CLIENT_FETCH_REGISTRY"              = "true"
      "EUREKA_CLIENT_SERVICEURL_DEFAULTZONE"      = "http://eureka-svc.test:8901/eureka/"
      "HEALTHCHECK"                               = "true"
      "JAVA_OPTS"                                 = "-Djava.awt.headless=true -Dsun.net.inetaddr.ttl=15"
      "JVM_OPTS"                                  = "-Xms1024m -Xmx1024m -XX:+UseG1GC -XX:MaxGCPauseMillis=200 -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/root/dump_bak"
    }
  }
}