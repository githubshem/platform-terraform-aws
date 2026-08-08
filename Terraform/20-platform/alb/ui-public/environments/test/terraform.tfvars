# ==========================================
# CORE NETWORKING & SECURITY
# ==========================================
aws_region          = "ap-southeast-1"
environment         = "test"
ssl_certificate_arn = "arn:aws:acm:ap-southeast-1:123456789012:certificate/11111111-2222-3333-4444-555555555555"

create_sg = false

project_tags = {
  Environment = "test"
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
    host_headers      = ["hera3-test.example.com"]
    priority          = 10
  }
  "hermes" = {
    container_port    = 80
    health_check_path = "/"
    host_headers      = ["hermes3-test.example.com"]
    priority          = 20
  }
  "artemis" = {
    container_port    = 80
    health_check_path = "/"
    host_headers      = ["artemis3-test.example.com"]
    priority          = 30
  }
  "athena" = {
    container_port    = 80
    health_check_path = "/"
    host_headers      = ["athena-test.example.com"]
    priority          = 40
  }
  "hestia" = {
    container_port    = 80
    health_check_path = "/"
    host_headers      = ["hestia3-test.example.com"]
    priority          = 50
  }
  "dionysus" = {
    container_port    = 80
    health_check_path = "/"
    host_headers      = ["selene-test.example.com"]
    priority          = 60
  }
  "nike" = {
    container_port    = 80
    health_check_path = "/"
    host_headers      = ["nike3-test.example.com"]
    priority          = 70
  }
  "orion" = {
    container_port    = 80
    health_check_path = "/"
    host_headers      = ["orion3-test.example.com"]
    priority          = 80
  }

  # ----------------------------------------
  # zeus SERVICES
  # ----------------------------------------
  "zeus-apollo" = {
    container_port    = 80
    health_check_path = "/"
    host_headers      = ["apollo-test.example.com"]
    priority          = 100
  }
  "zeus-zeus" = {
    container_port    = 80
    health_check_path = "/"
    host_headers      = ["zeus-test.example.com"]
    priority          = 110
  }
  "zeus-artemis" = {
    container_port    = 80
    health_check_path = "/"
    host_headers      = ["artemis-test.example.com"]
    priority          = 120
  }
  "zeus-hestia" = {
    container_port    = 80
    health_check_path = "/"
    host_headers      = ["hestia-test.example.com"]
    priority          = 130
  }
  "zeus-demeter" = {
    container_port    = 80
    health_check_path = "/"
    host_headers      = ["demeter-test.example.com"]
    priority          = 140
  }
  "zeus-helios" = {
    container_port    = 80
    health_check_path = "/"
    host_headers      = ["helios-test.example.com"]
    priority          = 150
  }
  "zeus-iris" = {
    container_port    = 80
    health_check_path = "/"
    host_headers      = ["iris-test.example.com"]
    priority          = 160
  }
  "zeus-proteus" = {
    container_port    = 80
    health_check_path = "/"
    host_headers      = ["proteus-test.example.com"]
    priority          = 170
  }
  "zeus-kronos" = {
    container_port    = 80
    health_check_path = "/"
    host_headers      = ["kronos-test.example.com"]
    priority          = 180
  }
  "zeus-morpheus" = {
    container_port    = 80
    health_check_path = "/"
    host_headers      = ["morpheus-test.example.com"]
    priority          = 190
  }
  "zeus-hades" = {
    container_port    = 80
    health_check_path = "/"
    host_headers      = ["hades-test.example.com"]
    priority          = 200
  }
  "zeus-hephaestus" = {
    container_port    = 80
    health_check_path = "/"
    host_headers      = ["hephaestus-test.example.com"]
    priority          = 210
  }
  "zeus-poseidon" = {
    container_port    = 80
    health_check_path = "/"
    host_headers      = ["poseidon-test.example.com"]
    priority          = 220
  }
  "zeus-ares-admin" = {
    container_port    = 80
    health_check_path = "/"
    host_headers      = ["ares-test.example.com"]
    priority          = 230
  }
  "zeus-triton" = {
    container_port    = 80
    health_check_path = "/"
    host_headers      = ["triton-test.example.com"]
    priority          = 240
  }
  "zeus-arachne-client" = {
    container_port    = 80
    health_check_path = "/"
    host_headers      = ["arachne-client-test.example.com"]
    priority          = 250
  }
  "zeus-hermes" = {
    container_port    = 80
    health_check_path = "/"
    host_headers      = ["hermes-test.example.com"]
    priority          = 260
  }
  "zeus-orion" = {
    container_port    = 80
    health_check_path = "/"
    host_headers      = ["orion-test.example.com"]
    priority          = 270
  }
  "zeus-ares-client" = {
    container_port    = 80
    health_check_path = "/"
    host_headers = [
      "ares-client-test.example.com",
      "eos-test.example.com"
    ]
    priority = 280
  }
  "zeus-thanatos" = {
    container_port    = 80
    health_check_path = "/"
    host_headers      = ["thanatos-test.example.com"]
    priority          = 290
  }
}