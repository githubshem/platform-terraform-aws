# ==========================================
# CORE NETWORKING & CLUSTER CONFIGURATION
# ==========================================
environment        = "test"
cluster_name       = "iris"
ami_id             = "ami-0ddd444eee555fff"
aws_region         = "ap-southeast-1"
container_insights = "disabled"
ec2_instance_type  = "r7i.large"
min_size           = 0
max_size           = 10
ec2_key_name       = "plat-test-services"

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
  "callback-iris" = {
    launch_type        = "EC2"
    provider           = "EC2_DYNAMIC"
    cpu                = 128
    memory             = 4096
    memory_reservation = 4096
    count              = 0
    port               = 9150
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-test-callback-iris:latest"
    host_volume_name   = ""
    host_volume_path   = ""
    target_group_arn   = []
    max_capacity       = 4
    cpu_target_value   = 75.0
    scale_out_cooldown = 180
    scale_in_cooldown  = 180
    cp_weight          = 100
    env_vars = {
      "SPRING_APPLICATION_NAME"                               = "callback-iris"
      "SPRING_PROFILES_ACTIVE"                                = "plat-test"
      "SERVER_PORT"                                           = "9150"
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
  "gateway-iris" = {
    launch_type        = "EC2"
    provider           = "EC2_DYNAMIC"
    cpu                = 128
    memory             = 4096
    memory_reservation = 4096
    count              = 0
    port               = 9160
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-test-gateway-iris:latest"
    host_volume_name   = ""
    host_volume_path   = ""
    target_group_arn   = ["arn:aws:elasticloadbalancing:ap-southeast-1:123456789012:targetgroup/gateway-iris-tg-test/275b4b25d76772ba"]
    max_capacity       = 4
    cpu_target_value   = 75.0
    scale_out_cooldown = 180
    scale_in_cooldown  = 180
    cp_weight          = 100
    env_vars = {
      "SPRING_APPLICATION_NAME"                               = "gateway-iris"
      "SPRING_PROFILES_ACTIVE"                                = "plat-test"
      "SERVER_PORT"                                           = "9160"
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
  "openapi-iris" = {
    launch_type        = "EC2"
    provider           = "EC2_DYNAMIC"
    cpu                = 128
    memory             = 12288
    memory_reservation = 12288
    count              = 0
    port               = 9161
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-test-openapi-iris:latest"
    host_volume_name   = ""
    host_volume_path   = ""
    target_group_arn   = ["arn:aws:elasticloadbalancing:ap-southeast-1:123456789012:targetgroup/openapi-iris-tg-test/ed634dbddf920684", "arn:aws:elasticloadbalancing:ap-southeast-1:123456789012:targetgroup/openapi-iris-test-tg/49f249b3f7119653"]
    max_capacity       = 4
    cpu_target_value   = 75.0
    scale_out_cooldown = 180
    scale_in_cooldown  = 180
    cp_weight          = 100
    env_vars = {
      "SPRING_APPLICATION_NAME"                               = "openapi-iris"
      "SPRING_PROFILES_ACTIVE"                                = "plat-test"
      "SERVER_PORT"                                           = "9161"
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
  "iris-config" = {
    launch_type        = "EC2"
    provider           = "EC2_DYNAMIC"
    cpu                = 128
    memory             = 4096
    memory_reservation = 4096
    count              = 0
    port               = 9162
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-test-iris-config:latest"
    host_volume_name   = ""
    host_volume_path   = ""
    target_group_arn   = []
    max_capacity       = 4
    cpu_target_value   = 75.0
    scale_out_cooldown = 180
    scale_in_cooldown  = 180
    cp_weight          = 100
    env_vars = {
      "SPRING_APPLICATION_NAME"                               = "iris-config"
      "SPRING_PROFILES_ACTIVE"                                = "plat-test"
      "SERVER_PORT"                                           = "9162"
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
  "iris-email" = {
    launch_type        = "EC2"
    provider           = "EC2_DYNAMIC"
    cpu                = 512
    memory             = 14336
    memory_reservation = 14336
    count              = 0
    port               = 9163
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-test-iris-email:latest"
    host_volume_name   = ""
    host_volume_path   = ""
    target_group_arn   = []
    max_capacity       = 13
    cpu_target_value   = 75.0
    scale_out_cooldown = 180
    scale_in_cooldown  = 180
    cp_weight          = 100
    env_vars = {
      "SPRING_APPLICATION_NAME"                               = "iris-email"
      "SPRING_PROFILES_ACTIVE"                                = "plat-test"
      "SERVER_PORT"                                           = "9163"
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
  "iris-metadata" = {
    launch_type        = "EC2"
    provider           = "EC2_DYNAMIC"
    cpu                = 128
    memory             = 4096
    memory_reservation = 4096
    count              = 0
    port               = 9164
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-test-iris-metadata:latest"
    host_volume_name   = ""
    host_volume_path   = ""
    target_group_arn   = []
    max_capacity       = 4
    cpu_target_value   = 75.0
    scale_out_cooldown = 180
    scale_in_cooldown  = 180
    cp_weight          = 100
    env_vars = {
      "SPRING_APPLICATION_NAME"                               = "iris-metadata"
      "SPRING_PROFILES_ACTIVE"                                = "plat-test"
      "SERVER_PORT"                                           = "9164"
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
  "iris-template" = {
    launch_type        = "EC2"
    provider           = "EC2_DYNAMIC"
    cpu                = 128
    memory             = 4096
    memory_reservation = 4096
    count              = 0
    port               = 9165
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-test-iris-template:latest"
    host_volume_name   = ""
    host_volume_path   = ""
    target_group_arn   = []
    max_capacity       = 4
    cpu_target_value   = 75.0
    scale_out_cooldown = 180
    scale_in_cooldown  = 180
    cp_weight          = 100
    env_vars = {
      "SPRING_APPLICATION_NAME"                               = "iris-template"
      "SPRING_PROFILES_ACTIVE"                                = "plat-test"
      "SERVER_PORT"                                           = "9165"
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
  "iris-workflow" = {
    launch_type        = "EC2"
    provider           = "EC2_DYNAMIC"
    cpu                = 128
    memory             = 4096
    memory_reservation = 4096
    count              = 0
    port               = 9166
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-test-iris-workflow:latest"
    host_volume_name   = ""
    host_volume_path   = ""
    target_group_arn   = []
    max_capacity       = 4
    cpu_target_value   = 75.0
    scale_out_cooldown = 180
    scale_in_cooldown  = 180
    cp_weight          = 100
    env_vars = {
      "SPRING_APPLICATION_NAME"                               = "iris-workflow"
      "SPRING_PROFILES_ACTIVE"                                = "plat-test"
      "SERVER_PORT"                                           = "9166"
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