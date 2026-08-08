environment = "prod"

# Updated to restrict SG ingress to this specific CIDR block

# Base name that gets appended with -environment automatically
alb_name = "zeus-alb"
project_tags = {
  "Project" = "ExampleCorp"
  "Team"    = "engineering"
}

alb_services = {
  "gateway-hermes" = {
    container_port    = 9098
    health_check_path = "/actuator/health"
  }
  "openapi-hermes" = {
    container_port    = 9099
    health_check_path = "/actuator/health"
  }
  "gateway-apollo" = {
    container_port    = 9102
    health_check_path = "/actuator/health"
  }
  "openapi-apollo" = {
    container_port    = 9103
    health_check_path = "/actuator/health"
  }
  "gateway-ares" = {
    container_port    = 9107
    health_check_path = "/actuator/health"
  }
  "openapi-ares" = {
    container_port    = 9109
    health_check_path = "/actuator/health"
  }
  "gateway-zeus" = {
    container_port    = 9116
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
  "gateway-hestia" = {
    container_port    = 9126
    health_check_path = "/actuator/health"
  }
  "openapi-hestia" = {
    container_port    = 9127
    health_check_path = "/actuator/health"
  }
  "gateway-demeter" = {
    container_port    = 9129
    health_check_path = "/actuator/health"
  }
  "openapi-demeter" = {
    container_port    = 9130
    health_check_path = "/actuator/health"
  }
  "gateway-hades" = {
    container_port    = 9132
    health_check_path = "/actuator/health"
  }
  "openapi-hades" = {
    container_port    = 9137
    health_check_path = "/actuator/health"
  }
  "gateway-hephaestus" = {
    container_port    = 9138
    health_check_path = "/actuator/health"
  }
  "openapi-hephaestus" = {
    container_port    = 9141
    health_check_path = "/actuator/health"
  }
  "gateway-helios" = {
    container_port    = 9142
    health_check_path = "/actuator/health"
  }
  "openapi-helios" = {
    container_port    = 9148
    health_check_path = "/actuator/health"
  }
  "gateway-iris" = {
    container_port    = 9160
    health_check_path = "/actuator/health"
  }
  "openapi-iris" = {
    container_port    = 9161
    health_check_path = "/actuator/health"
  }
  "gateway-triton" = {
    container_port    = 9167
    health_check_path = "/actuator/health"
  }
  "openapi-triton" = {
    container_port    = 9168
    health_check_path = "/actuator/health"
  }
  "gateway-nereus" = {
    container_port    = 9176
    health_check_path = "/actuator/health"
  }
  "gateway-proteus" = {
    container_port    = 9177
    health_check_path = "/actuator/health"
  }
  "openapi-proteus" = {
    container_port    = 9178
    health_check_path = "/actuator/health"
  }
  "gateway-arachne" = {
    container_port    = 9180
    health_check_path = "/actuator/health"
  }
  "openapi-arachne" = {
    container_port    = 9181
    health_check_path = "/actuator/health"
  }
  "gateway-kronos" = {
    container_port    = 9183
    health_check_path = "/actuator/health"
  }
  "openapi-kronos" = {
    container_port    = 9184
    health_check_path = "/actuator/health"
  }
  "gateway-morpheus" = {
    container_port    = 9192
    health_check_path = "/actuator/health"
  }
  "gateway-orion" = {
    container_port    = 9195
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