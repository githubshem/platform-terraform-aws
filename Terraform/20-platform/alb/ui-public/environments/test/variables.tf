variable "aws_region" { type = string }
variable "environment" { type = string }
variable "ssl_certificate_arn" { type = string }
variable "create_sg" { type = bool }
variable "project_tags" { type = map(string) }

# Simplified! Only networking data now.
variable "ui_services" {
  type = map(object({
    container_port    = number
    health_check_path = string
    host_headers      = list(string)
    priority          = number
  }))
}