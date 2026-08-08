environment               = "prod"
cluster_name              = "metis"
ami_id                    = "ami-0ddd444eee555fff"
aws_region                = "ap-southeast-1"
container_insights        = "disabled"
ec2_instance_type         = "r7i.large"
min_size                  = 0
max_size                  = 10
ecs_instance_profile_name = "ecsInstanceRole"
ecs_execution_role_arn    = "arn:aws:iam::123456789012:role/ecsTaskExecutionRole"
ecs_task_role_arn         = "arn:aws:iam::123456789012:role/ecsTaskRole"
target_capacity           = 100
default_cp_weight         = 100
cloudwatch_retention_days = 30
placement_strategy_type   = "binpack"
placement_strategy_field  = "memory"
az_rebalancing            = "DISABLED"
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
  "microservice-configuration" = {
    launch_type        = "EC2"
    provider           = "EC2_DYNAMIC"
    cpu                = 512
    memory             = 2048
    memory_reservation = 2048
    count              = 0
    port               = 8205
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-prod-microservice-configuration:latest"
    host_volume_name   = "awseb-logs-microservice-configuration-test"
    host_volume_path   = "/var/log/containers/microservice-configuration-test"
    target_group_arn   = ["arn:aws:elasticloadbalancing:ap-southeast-1:123456789012:targetgroup/microservice-configuration-tg-up/e2e1e1e6ee4bd798"]

    max_capacity       = 4
    cpu_target_value   = 75.0
    scale_out_cooldown = 180
    scale_in_cooldown  = 180
    cp_weight          = 100

    env_vars = {
      "SPRING_APPLICATION_NAME"                               = "configuration-restapi"
      "SPRING_PROFILES_ACTIVE"                                = "plat-prod"
      "SERVER_PORT"                                           = "8205"
      "EUREKA_INSTANCE_INSTANCE_ID"                           = "$${spring.cloud.client.ip-address}:$${server.port}"
      "EUREKA_INSTANCE_PREFER_IP_ADDRESS"                     = "true"
      "SPRING_CLOUD_INETUTILS_USE_ONLY_SITE_LOCAL_INTERFACES" = "true"
      "EUREKA_CLIENT_REGISTER_WITH_EUREKA"                    = "true"
      "EUREKA_CLIENT_FETCH_REGISTRY"                          = "true"
      "EUREKA_CLIENT_SERVICEURL_DEFAULTZONE"                  = "http://eureka-svc.prod:8901/eureka/"
      "HEALTHCHECK"                                           = "true"
      "JAVA_OPTS"                                             = "-Djava.awt.headless=true -Dsun.net.inetaddr.ttl=5 -Dsun.net.inetaddr.negative.ttl=3"
      "JVM_OPTS"                                              = "-Xms1024m -Xmx1024m -XX:+UseG1GC -XX:MaxGCPauseMillis=200 -Xlog:gc*,safepoint:stdout:time,level,tags -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/root/dump_bak -XX:+ExitOnOutOfMemoryError"
    }
  },

  "microservice-employee" = {
    launch_type        = "EC2"
    provider           = "EC2_DYNAMIC"
    cpu                = 512
    memory             = 2048
    memory_reservation = 2048
    count              = 0
    port               = 8204
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-prod-microservice-employee:latest"
    host_volume_name   = ""
    host_volume_path   = ""
    target_group_arn   = ["arn:aws:elasticloadbalancing:ap-southeast-1:123456789012:targetgroup/employee-tg-prod/b5d874f201cac939"]

    max_capacity       = 4
    cpu_target_value   = 75.0
    scale_out_cooldown = 180
    scale_in_cooldown  = 180
    cp_weight          = 100

    env_vars = {
      "SPRING_APPLICATION_NAME"                               = "employee-restapi"
      "SPRING_PROFILES_ACTIVE"                                = "plat-prod"
      "SERVER_PORT"                                           = "8204"
      "EUREKA_INSTANCE_INSTANCE_ID"                           = "$${spring.cloud.client.ip-address}:$${server.port}"
      "EUREKA_INSTANCE_PREFER_IP_ADDRESS"                     = "true"
      "SPRING_CLOUD_INETUTILS_USE_ONLY_SITE_LOCAL_INTERFACES" = "true"
      "EUREKA_CLIENT_REGISTER_WITH_EUREKA"                    = "true"
      "EUREKA_CLIENT_FETCH_REGISTRY"                          = "true"
      "EUREKA_CLIENT_SERVICEURL_DEFAULTZONE"                  = "http://eureka-svc.prod:8901/eureka/"
      "HEALTHCHECK"                                           = "true"
      "JAVA_OPTS"                                             = "-Djava.awt.headless=true -Dsun.net.inetaddr.ttl=5 -Dsun.net.inetaddr.negative.ttl=3"
      "JVM_OPTS"                                              = "-Xms1024m -Xmx1024m -XX:+UseG1GC -XX:MaxGCPauseMillis=200 -Xlog:gc*,safepoint:stdout:time,level,tags -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/root/dump_bak -XX:+ExitOnOutOfMemoryError"
    }
  },

  "microservice-lookup" = {
    launch_type        = "EC2"
    provider           = "EC2_DYNAMIC"
    cpu                = 512
    memory             = 2048
    memory_reservation = 2048
    count              = 0
    port               = 8201
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-prod-microservice-lookup:latest"
    host_volume_name   = ""
    host_volume_path   = ""
    target_group_arn   = ["arn:aws:elasticloadbalancing:ap-southeast-1:123456789012:targetgroup/dictionary-tg-prod/b9b34dc374ef24d6"]

    max_capacity       = 4
    cpu_target_value   = 75.0
    scale_out_cooldown = 180
    scale_in_cooldown  = 180
    cp_weight          = 100

    env_vars = {
      "SPRING_APPLICATION_NAME"                               = "dictionary-restapi"
      "SPRING_PROFILES_ACTIVE"                                = "plat-prod"
      "SERVER_PORT"                                           = "8201"
      "EUREKA_INSTANCE_INSTANCE_ID"                           = "$${spring.cloud.client.ip-address}:$${server.port}"
      "EUREKA_INSTANCE_PREFER_IP_ADDRESS"                     = "true"
      "SPRING_CLOUD_INETUTILS_USE_ONLY_SITE_LOCAL_INTERFACES" = "true"
      "EUREKA_CLIENT_REGISTER_WITH_EUREKA"                    = "true"
      "EUREKA_CLIENT_FETCH_REGISTRY"                          = "true"
      "EUREKA_CLIENT_SERVICEURL_DEFAULTZONE"                  = "http://eureka-svc.prod:8901/eureka/"
      "HEALTHCHECK"                                           = "true"
      "JAVA_OPTS"                                             = "-Djava.awt.headless=true -Dsun.net.inetaddr.ttl=5 -Dsun.net.inetaddr.negative.ttl=3"
      "JVM_OPTS"                                              = "-Xms1024m -Xmx1024m -XX:+UseG1GC -XX:MaxGCPauseMillis=200 -Xlog:gc*,safepoint:stdout:time,level,tags -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/root/dump_bak -XX:+ExitOnOutOfMemoryError"
    }
  },

  "microservice-oauth" = {
    launch_type        = "EC2"
    provider           = "EC2_DYNAMIC"
    cpu                = 512
    memory             = 4096
    memory_reservation = 4096
    count              = 0
    port               = 8102
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-prod-microservice-oauth:latest"
    host_volume_name   = ""
    host_volume_path   = ""
    target_group_arn   = ["arn:aws:elasticloadbalancing:ap-southeast-1:123456789012:targetgroup/oauth-tg-prod/0e0bc71d91006abe"]

    max_capacity       = 4
    cpu_target_value   = 75.0
    scale_out_cooldown = 180
    scale_in_cooldown  = 180
    cp_weight          = 100

    env_vars = {
      "SPRING_APPLICATION_NAME"                               = "oauth-restapi"
      "SPRING_PROFILES_ACTIVE"                                = "plat-prod"
      "SERVER_PORT"                                           = "8102"
      "EUREKA_INSTANCE_INSTANCE_ID"                           = "$${spring.cloud.client.ip-address}:$${server.port}"
      "EUREKA_INSTANCE_PREFER_IP_ADDRESS"                     = "true"
      "SPRING_CLOUD_INETUTILS_USE_ONLY_SITE_LOCAL_INTERFACES" = "true"
      "EUREKA_CLIENT_REGISTER_WITH_EUREKA"                    = "true"
      "EUREKA_CLIENT_FETCH_REGISTRY"                          = "true"
      "EUREKA_CLIENT_SERVICEURL_DEFAULTZONE"                  = "http://eureka-svc.prod:8901/eureka/"
      "HEALTHCHECK"                                           = "true"
      "JAVA_OPTS"                                             = "-Djava.awt.headless=true -Dsun.net.inetaddr.ttl=5 -Dsun.net.inetaddr.negative.ttl=3"
      "JVM_OPTS"                                              = "-Xms2048m -Xmx2048m -XX:+UseG1GC -XX:MaxGCPauseMillis=200 -Xlog:gc*,safepoint:stdout:time,level,tags -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/root/dump_bak -XX:+ExitOnOutOfMemoryError"
    }
  },

  "microservice-tenant" = {
    launch_type        = "EC2"
    provider           = "EC2_DYNAMIC"
    cpu                = 512
    memory             = 2048
    memory_reservation = 2048
    count              = 0
    port               = 8203
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-prod-microservice-tenant:latest"
    host_volume_name   = "awseb-logs-microservice-tenant-test"
    host_volume_path   = "/var/log/containers/microservice-tenant-test"
    target_group_arn   = []

    max_capacity       = 4
    cpu_target_value   = 75.0
    scale_out_cooldown = 180
    scale_in_cooldown  = 180
    cp_weight          = 100

    env_vars = {
      "SPRING_APPLICATION_NAME"                               = "organization-restapi"
      "SPRING_PROFILES_ACTIVE"                                = "plat-prod"
      "SERVER_PORT"                                           = "8203"
      "EUREKA_INSTANCE_INSTANCE_ID"                           = "$${spring.cloud.client.ip-address}:$${server.port}"
      "EUREKA_INSTANCE_PREFER_IP_ADDRESS"                     = "true"
      "SPRING_CLOUD_INETUTILS_USE_ONLY_SITE_LOCAL_INTERFACES" = "true"
      "EUREKA_CLIENT_REGISTER_WITH_EUREKA"                    = "true"
      "EUREKA_CLIENT_FETCH_REGISTRY"                          = "true"
      "EUREKA_CLIENT_SERVICEURL_DEFAULTZONE"                  = "http://eureka-svc.prod:8901/eureka/"
      "HEALTHCHECK"                                           = "true"
      "JAVA_OPTS"                                             = "-Djava.awt.headless=true -Dsun.net.inetaddr.ttl=5 -Dsun.net.inetaddr.negative.ttl=3"
      "JVM_OPTS"                                              = "-Xms1024m -Xmx1024m -XX:+UseG1GC -XX:MaxGCPauseMillis=200 -Xlog:gc*,safepoint:stdout:time,level,tags -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/root/dump_bak -XX:+ExitOnOutOfMemoryError"
    }
  },

  "microservice-transmission" = {
    launch_type        = "EC2"
    provider           = "EC2_DYNAMIC"
    cpu                = 512
    memory             = 4096
    memory_reservation = 4096
    count              = 0
    port               = 8404
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-prod-microservice-transmission:latest"
    host_volume_name   = "awseb-logs-microservice-transmission-test"
    host_volume_path   = "/var/log/containers/microservice-transmission-test"
    target_group_arn   = []

    max_capacity       = 4
    cpu_target_value   = 75.0
    scale_out_cooldown = 180
    scale_in_cooldown  = 180
    cp_weight          = 100

    env_vars = {
      "SPRING_APPLICATION_NAME"                               = "transmission-restapi"
      "SPRING_PROFILES_ACTIVE"                                = "plat-prod"
      "SERVER_PORT"                                           = "8404"
      "EUREKA_INSTANCE_INSTANCE_ID"                           = "$${spring.cloud.client.ip-address}:$${server.port}"
      "EUREKA_INSTANCE_PREFER_IP_ADDRESS"                     = "true"
      "SPRING_CLOUD_INETUTILS_USE_ONLY_SITE_LOCAL_INTERFACES" = "true"
      "EUREKA_CLIENT_REGISTER_WITH_EUREKA"                    = "true"
      "EUREKA_CLIENT_FETCH_REGISTRY"                          = "true"
      "EUREKA_CLIENT_SERVICEURL_DEFAULTZONE"                  = "http://eureka-svc.prod:8901/eureka/"
      "HEALTHCHECK"                                           = "true"
      "JAVA_OPTS"                                             = "-Djava.awt.headless=true -Dsun.net.inetaddr.ttl=5 -Dsun.net.inetaddr.negative.ttl=3"
      "JVM_OPTS"                                              = "-Xms2048m -Xmx2048m -XX:+UseG1GC -XX:MaxGCPauseMillis=200 -Xlog:gc*,safepoint:stdout:time,level,tags -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/root/dump_bak -XX:+ExitOnOutOfMemoryError"
    }
  },

  "microservice-workflow" = {
    launch_type        = "EC2"
    provider           = "EC2_DYNAMIC"
    cpu                = 512
    memory             = 4096
    memory_reservation = 4096
    count              = 0
    port               = 8301
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-prod-microservice-workflow:latest"
    host_volume_name   = ""
    host_volume_path   = ""
    target_group_arn   = ["arn:aws:elasticloadbalancing:ap-southeast-1:123456789012:targetgroup/workflow-tg-prod/8d1b2632e6725fa0"]

    max_capacity       = 4
    cpu_target_value   = 75.0
    scale_out_cooldown = 180
    scale_in_cooldown  = 180
    cp_weight          = 100

    env_vars = {
      "SPRING_APPLICATION_NAME"                               = "workflow-restapi"
      "SPRING_PROFILES_ACTIVE"                                = "plat-prod"
      "SERVER_PORT"                                           = "8301"
      "EUREKA_INSTANCE_INSTANCE_ID"                           = "$${spring.cloud.client.ip-address}:$${server.port}"
      "EUREKA_INSTANCE_PREFER_IP_ADDRESS"                     = "true"
      "SPRING_CLOUD_INETUTILS_USE_ONLY_SITE_LOCAL_INTERFACES" = "true"
      "EUREKA_CLIENT_REGISTER_WITH_EUREKA"                    = "true"
      "EUREKA_CLIENT_FETCH_REGISTRY"                          = "true"
      "EUREKA_CLIENT_SERVICEURL_DEFAULTZONE"                  = "http://eureka-svc.prod:8901/eureka/"
      "HEALTHCHECK"                                           = "true"
      "JAVA_OPTS"                                             = "-Djava.awt.headless=true -Dsun.net.inetaddr.ttl=5 -Dsun.net.inetaddr.negative.ttl=3"
      "JVM_OPTS"                                              = "-Xms2048m -Xmx2048m -XX:+UseG1GC -XX:MaxGCPauseMillis=200 -Xlog:gc*,safepoint:stdout:time,level,tags -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/root/dump_bak -XX:+ExitOnOutOfMemoryError"
    }
  },

  "microservice-intake" = {
    launch_type        = "EC2"
    provider           = "EC2_DYNAMIC"
    cpu                = 512
    memory             = 4096
    memory_reservation = 4096
    count              = 0
    port               = 8303
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-prod-microservice-intake:latest"
    host_volume_name   = ""
    host_volume_path   = ""
    target_group_arn   = ["arn:aws:elasticloadbalancing:ap-southeast-1:123456789012:targetgroup/intake-tg-prod/6603ac165a3ca82f"]

    max_capacity       = 4
    cpu_target_value   = 75.0
    scale_out_cooldown = 180
    scale_in_cooldown  = 180
    cp_weight          = 100

    env_vars = {
      "SPRING_APPLICATION_NAME"                               = "intake-restapi"
      "SPRING_PROFILES_ACTIVE"                                = "plat-prod"
      "SERVER_PORT"                                           = "8303"
      "EUREKA_INSTANCE_INSTANCE_ID"                           = "$${spring.cloud.client.ip-address}:$${server.port}"
      "EUREKA_INSTANCE_PREFER_IP_ADDRESS"                     = "true"
      "SPRING_CLOUD_INETUTILS_USE_ONLY_SITE_LOCAL_INTERFACES" = "true"
      "EUREKA_CLIENT_REGISTER_WITH_EUREKA"                    = "true"
      "EUREKA_CLIENT_FETCH_REGISTRY"                          = "true"
      "EUREKA_CLIENT_SERVICEURL_DEFAULTZONE"                  = "http://eureka-svc.prod:8901/eureka/"
      "HEALTHCHECK"                                           = "true"
      "JAVA_OPTS"                                             = "-Djava.awt.headless=true -Dsun.net.inetaddr.ttl=5 -Dsun.net.inetaddr.negative.ttl=3"
      "JVM_OPTS"                                              = "-Xms2048m -Xmx2048m -XX:+UseG1GC -XX:MaxGCPauseMillis=200 -Xlog:gc*,safepoint:stdout:time,level,tags -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/root/dump_bak -XX:+ExitOnOutOfMemoryError"
    }
  },

  "microservice-staging" = {
    launch_type        = "EC2"
    provider           = "EC2_DYNAMIC"
    cpu                = 512
    memory             = 2048
    memory_reservation = 2048
    count              = 0
    port               = 8305
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-prod-microservice-staging:latest"
    host_volume_name   = ""
    host_volume_path   = ""
    target_group_arn   = []

    max_capacity       = 4
    cpu_target_value   = 75.0
    scale_out_cooldown = 180
    scale_in_cooldown  = 180
    cp_weight          = 100

    env_vars = {
      "SPRING_APPLICATION_NAME"                               = "temporary-restapi"
      "SPRING_PROFILES_ACTIVE"                                = "plat-prod"
      "SERVER_PORT"                                           = "8305"
      "EUREKA_INSTANCE_INSTANCE_ID"                           = "$${spring.cloud.client.ip-address}:$${server.port}"
      "EUREKA_INSTANCE_PREFER_IP_ADDRESS"                     = "true"
      "SPRING_CLOUD_INETUTILS_USE_ONLY_SITE_LOCAL_INTERFACES" = "true"
      "EUREKA_CLIENT_REGISTER_WITH_EUREKA"                    = "true"
      "EUREKA_CLIENT_FETCH_REGISTRY"                          = "true"
      "EUREKA_CLIENT_SERVICEURL_DEFAULTZONE"                  = "http://eureka-svc.prod:8901/eureka/"
      "HEALTHCHECK"                                           = "true"
      "JAVA_OPTS"                                             = "-Djava.awt.headless=true -Dsun.net.inetaddr.ttl=5 -Dsun.net.inetaddr.negative.ttl=3"
      "JVM_OPTS"                                              = "-Xms1024m -Xmx1024m -XX:+UseG1GC -XX:MaxGCPauseMillis=200 -Xlog:gc*,safepoint:stdout:time,level,tags -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/root/dump_bak -XX:+ExitOnOutOfMemoryError"
    }
  },

  "openapi-hera" = {
    launch_type        = "EC2"
    provider           = "EC2_DYNAMIC"
    cpu                = 512
    memory             = 4096
    memory_reservation = 4096
    count              = 0
    port               = 8104
    image              = "123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/plat-prod-openapi-hera:latest"
    host_volume_name   = ""
    host_volume_path   = ""
    target_group_arn   = ["arn:aws:elasticloadbalancing:ap-southeast-1:123456789012:targetgroup/openapi-hera-tg-prod/22b4d8f2c2d25c7f"]

    max_capacity       = 4
    cpu_target_value   = 75.0
    scale_out_cooldown = 180
    scale_in_cooldown  = 180
    cp_weight          = 100

    env_vars = {
      "SPRING_APPLICATION_NAME"                               = "openapi-hera-restapi"
      "SPRING_PROFILES_ACTIVE"                                = "plat-prod"
      "SERVER_PORT"                                           = "8104"
      "EUREKA_INSTANCE_INSTANCE_ID"                           = "$${spring.cloud.client.ip-address}:$${server.port}"
      "EUREKA_INSTANCE_PREFER_IP_ADDRESS"                     = "true"
      "SPRING_CLOUD_INETUTILS_USE_ONLY_SITE_LOCAL_INTERFACES" = "true"
      "EUREKA_CLIENT_REGISTER_WITH_EUREKA"                    = "true"
      "EUREKA_CLIENT_FETCH_REGISTRY"                          = "true"
      "EUREKA_CLIENT_SERVICEURL_DEFAULTZONE"                  = "http://eureka-svc.prod:8901/eureka/"
      "HEALTHCHECK"                                           = "true"
      "JAVA_OPTS"                                             = "-Djava.awt.headless=true -Dsun.net.inetaddr.ttl=5 -Dsun.net.inetaddr.negative.ttl=3"
      "JVM_OPTS"                                              = "-Xms2048m -Xmx2048m -XX:+UseG1GC -XX:MaxGCPauseMillis=200 -Xlog:gc*,safepoint:stdout:time,level,tags -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/root/dump_bak -XX:+ExitOnOutOfMemoryError"
    }
  }
}