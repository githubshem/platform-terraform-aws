# The VPC stack is the source of truth for network identifiers. Reading its
# published state removes the hardcoded vpc-* value this workspace used to carry
# and guarantees the two stacks can never drift apart.
data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = "plat-test-terraform-state"
    key    = "test/vpc/terraform.tfstate"
    region = "ap-southeast-1"
  }
}

module "security_groups" {
  source = "../../modules/security-groups"

  environment  = var.environment
  project_name = var.project_name
  vpc_id       = data.terraform_remote_state.vpc.outputs.vpc_id

  fe_http_ports    = var.fe_http_ports
  fe_https_ports   = var.fe_https_ports
  db_ports         = var.db_ports
  redis_ports      = var.redis_ports
  opensearch_ports = var.opensearch_ports
  gelf_ports       = var.gelf_ports
  rabbitmq_ports   = var.rabbitmq_ports

  egress_cidr_blocks = var.egress_cidr_blocks
  project_tags       = var.project_tags
}
