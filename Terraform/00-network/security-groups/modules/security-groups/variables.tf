variable "environment" { type = string }
variable "project_name" { type = string }
variable "vpc_id" { type = string }

variable "fe_http_ports" { type = list(number) }
variable "fe_https_ports" { type = list(number) }

variable "db_ports" {
  type        = list(number)
  description = "Database listener ports. Aurora MySQL listens on 3306."
}

variable "redis_ports" { type = list(number) }
variable "opensearch_ports" { type = list(number) }
variable "gelf_ports" { type = list(number) }

variable "rabbitmq_ports" {
  type        = list(number)
  description = "List of ports used for RabbitMQ"
  default     = [5671, 5672, 15671, 15672]
}

variable "egress_cidr_blocks" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = <<-EOT
    Destination CIDRs for egress rules. Defaults to unrestricted because worker
    nodes and tasks need registry, AWS API, and add-on traffic that is awkward to
    enumerate. Narrow this once VPC endpoints cover those calls; it is the single
    remaining Trivy AWS-0104 finding by design, not by oversight.
  EOT
}

variable "project_tags" {
  type        = map(string)
  default     = {}
  description = "Tags merged onto every security group."
}
