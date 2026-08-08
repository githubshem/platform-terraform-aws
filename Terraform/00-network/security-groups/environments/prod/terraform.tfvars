aws_region   = "ap-southeast-1"
environment  = "prod"
project_name = "plat"

# vpc_id is not set here. It is read from the VPC stack's remote state.

# --- Port configuration ---
fe_http_ports  = [80]
fe_https_ports = [443]

# Aurora MySQL listens on 3306. This previously read 5432 (PostgreSQL), which
# left the actual database port closed on the shared backend group.
db_ports = [3306]

redis_ports      = [6379]
opensearch_ports = [443]
gelf_ports       = [12201]
rabbitmq_ports   = [5671, 5672, 15671, 15672]

project_tags = {
  Project     = "ExampleCorp"
  Environment = "prod"
  Team        = "engineering"
  ManagedBy   = "terraform"
}
