environment = "test"

# Exact ALB name requested.
alb_name = "plat-test-backend-dns-alb"

project_tags = {
  Environment = "test"
  Project     = "ExampleCorp"
  Team        = "engineering"
  Stack       = "openapi-dns"
}

# Imported from zeus ALB openapi services.
alb_services = {
  "openapi-hermes" = {
    container_port    = 9099
    health_check_path = "/actuator/health"
  }
  "openapi-apollo" = {
    container_port    = 9103
    health_check_path = "/actuator/health"
  }
  "openapi-ares" = {
    container_port    = 9109
    health_check_path = "/actuator/health"
  }
  "openapi-zeus" = {
    container_port    = 9117
    health_check_path = "/actuator/health"
  }
  "openapi-artemis" = {
    container_port    = 9122
    health_check_path = "/actuator/health"
  }
  "openapi-hestia" = {
    container_port    = 9127
    health_check_path = "/actuator/health"
  }
  "openapi-demeter" = {
    container_port    = 9130
    health_check_path = "/actuator/health"
  }
  "openapi-hades" = {
    container_port    = 9137
    health_check_path = "/actuator/health"
  }
  "openapi-hephaestus" = {
    container_port    = 9141
    health_check_path = "/actuator/health"
  }
  "openapi-helios" = {
    container_port    = 9148
    health_check_path = "/actuator/health"
  }
  "openapi-iris" = {
    container_port    = 9161
    health_check_path = "/actuator/health"
  }
  "openapi-triton" = {
    container_port    = 9168
    health_check_path = "/actuator/health"
  }
  "openapi-proteus" = {
    container_port    = 9178
    health_check_path = "/actuator/health"
  }
  "openapi-arachne" = {
    container_port    = 9181
    health_check_path = "/actuator/health"
  }
  "openapi-kronos" = {
    container_port    = 9184
    health_check_path = "/actuator/health"
  }
  "openapi-orion" = {
    container_port    = 9196
    health_check_path = "/actuator/health"
  }
  "openapi-filter" = {
    container_port    = 9199
    health_check_path = "/actuator/health"
  }
  "openapi-rhea" = {
    container_port    = 9203
    health_check_path = "/actuator/health"
  }
}
