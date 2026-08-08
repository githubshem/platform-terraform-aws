variable "aws_region" { type = string }
variable "environment" { type = string }
variable "project_name" { type = string }

# vpc_id is intentionally absent: it comes from the VPC stack's remote state.

variable "fe_http_ports" { type = list(number) }
variable "fe_https_ports" { type = list(number) }
variable "db_ports" { type = list(number) }
variable "redis_ports" { type = list(number) }
variable "opensearch_ports" { type = list(number) }
variable "gelf_ports" { type = list(number) }

variable "rabbitmq_ports" {
  type    = list(number)
  default = [5671, 5672, 15671, 15672]
}

variable "egress_cidr_blocks" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable "project_tags" {
  type    = map(string)
  default = {}
}
