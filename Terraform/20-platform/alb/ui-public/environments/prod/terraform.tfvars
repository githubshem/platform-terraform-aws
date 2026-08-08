# ==========================================
# CORE NETWORKING & SECURITY
# ==========================================
aws_region          = "ap-southeast-1"
environment         = "prod"
ssl_certificate_arn = "arn:aws:acm:ap-southeast-1:123456789012:certificate/11111111-2222-3333-4444-555555555555"

create_sg = false

project_tags = {
  Environment = "prod"
  Project     = "plat-hera-zeus"
  CostCenter  = "ExampleCorp"
  ManagedBy   = "terraform"
}

# ==========================================
# LOAD BALANCER PORTALS & ROUTING
# ==========================================
ui_services = {

  # ----------------------------------------
  # hera SERVICES
  # ----------------------------------------
  "hera" = {
    container_port    = 80
    health_check_path = "/"
    host_headers      = ["hera3-prod.example.com"]
    priority          = 10
  }
  "hermes" = {
    container_port    = 80
    health_check_path = "/"
    host_headers      = ["hermes3-prod.example.com"]
    priority          = 20
  }
  "artemis" = {
    container_port    = 80
    health_check_path = "/"
    host_headers      = ["artemis3-prod.example.com"]
    priority          = 30
  }
  "athena" = {
    container_port    = 80
    health_check_path = "/"
    host_headers      = ["athena-prod.example.com"]
    priority          = 40
  }
  "hestia" = {
    container_port    = 80
    health_check_path = "/"
    host_headers      = ["hestia3-prod.example.com"]
    priority          = 50
  }
  "dionysus" = {
    container_port    = 80
    health_check_path = "/"
    host_headers      = ["selene-prod.example.com"]
    priority          = 60
  }
  "nike" = {
    container_port    = 80
    health_check_path = "/"
    host_headers      = ["nike-prod.example.com"]
    priority          = 70
  }
  "orion" = {
    container_port    = 80
    health_check_path = "/"
    host_headers      = ["orion3-prod.example.com"]
    priority          = 80
  }

  # ----------------------------------------
  # zeus SERVICES
  # ----------------------------------------
  "zeus-apollo" = {
    container_port    = 80
    health_check_path = "/"
    host_headers      = ["apollo-prod.example.com"]
    priority          = 100
  }
  "zeus-zeus" = {
    container_port    = 80
    health_check_path = "/"
    host_headers      = ["zeus-prod.example.com"]
    priority          = 110
  }
  "zeus-artemis" = {
    container_port    = 80
    health_check_path = "/"
    host_headers      = ["artemis-prod.example.com"]
    priority          = 120
  }
  "zeus-hestia" = {
    container_port    = 80
    health_check_path = "/"
    host_headers      = ["hestia-prod.example.com"]
    priority          = 130
  }
  "zeus-demeter" = {
    container_port    = 80
    health_check_path = "/"
    host_headers      = ["demeter-prod.example.com"]
    priority          = 140
  }
  "zeus-helios" = {
    container_port    = 80
    health_check_path = "/"
    host_headers      = ["helios-prod.example.com"]
    priority          = 150
  }
  "zeus-iris" = {
    container_port    = 80
    health_check_path = "/"
    host_headers      = ["iris-prod.example.com"]
    priority          = 160
  }
  "zeus-proteus" = {
    container_port    = 80
    health_check_path = "/"
    host_headers      = ["proteus-prod.example.com"]
    priority          = 170
  }
  "zeus-kronos" = {
    container_port    = 80
    health_check_path = "/"
    host_headers      = ["kronos-prod.example.com"]
    priority          = 180
  }
  "zeus-morpheus" = {
    container_port    = 80
    health_check_path = "/"
    host_headers      = ["morpheus-prod.example.com"]
    priority          = 190
  }
  "zeus-hades" = {
    container_port    = 80
    health_check_path = "/"
    host_headers      = ["hades-prod.example.com"]
    priority          = 200
  }
  "zeus-hephaestus" = {
    container_port    = 80
    health_check_path = "/"
    host_headers      = ["hephaestus-prod.example.com"]
    priority          = 210
  }
  "zeus-poseidon" = {
    container_port    = 80
    health_check_path = "/"
    host_headers      = ["poseidon-prod.example.com"]
    priority          = 220
  }
  "zeus-ares-admin" = {
    container_port    = 80
    health_check_path = "/"
    host_headers      = ["ares-admin-prod.example.com"]
    priority          = 230
  }
  "zeus-triton" = {
    container_port    = 80
    health_check_path = "/"
    host_headers      = ["triton-prod.example.com"]
    priority          = 240
  }
  "zeus-arachne-client" = {
    container_port    = 80
    health_check_path = "/"
    host_headers      = ["arachne-client-prod.example.com"]
    priority          = 250
  }
  "zeus-hermes" = {
    container_port    = 80
    health_check_path = "/"
    host_headers      = ["hermes-prod.example.com"]
    priority          = 260
  }
  "zeus-orion" = {
    container_port    = 80
    health_check_path = "/"
    host_headers      = ["orion-prod.example.com"]
    priority          = 270
  }
  "zeus-ares-client" = {
    container_port    = 80
    health_check_path = "/"
    host_headers = [
      "ares-client-prod.example.com",
      "eos-prod.example.com"
    ]
    priority = 280
  }
  "zeus-thanatos" = {
    container_port    = 80
    health_check_path = "/"
    host_headers      = ["thanatos-prod.example.com"]
    priority          = 290
  }
}