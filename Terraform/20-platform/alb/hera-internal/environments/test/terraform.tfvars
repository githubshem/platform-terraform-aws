environment = "test"
aws_region  = "ap-southeast-1"

alb_services = {
  "eureka" = {
    port              = 8901
    health_check_path = "/actuator/health"
  },
  "config" = {
    port              = 8902
    health_check_path = "/actuator/health"
  },
  "gateway" = {
    port              = 8910
    health_check_path = "/actuator/health"
  },
  "dictionary" = {
    port              = 8201
    health_check_path = "/v3/actuator/health"
  },
  "employee" = {
    port              = 8204
    health_check_path = "/v3/actuator/health"
  },
  "workflow" = {
    port              = 8301
    health_check_path = "/v3/actuator/health"
  },
  "metadata" = {
    port              = 8202
    health_check_path = "/v3/actuator/health"
  },
  "oauth" = {
    port              = 8102
    health_check_path = "/v3/actuator/health"
  },
  "intake" = {
    port              = 8303
    health_check_path = "/v3/actuator/health"
  },
  "scheduler" = {
    port              = 8406
    health_check_path = "/v3/actuator/health"
  },
  "openapi-hera" = {
    port              = 8104
    health_check_path = "/v3/actuator/health"
  },
  "platform-coreapi" = {
    port              = 8803
    health_check_path = "/v3/actuator/health"
  },
  "platform-adminapi" = {
    port              = 8802
    health_check_path = "/v3/actuator/health"
  },
  "platform-openapi" = {
    port              = 8801
    health_check_path = "/v3/actuator/health"
  },
  "compress-server" = {
    port              = 8907
    health_check_path = "/v3/actuator/health" # Assuming standard v3 path
  },
  "microservice-configuration" = {
    port              = 8205
    health_check_path = "/v3/actuator/health"
  }
}