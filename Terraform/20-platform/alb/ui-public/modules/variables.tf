variable "aws_region" { type = string }
variable "environment" { type = string }
variable "vpc_id" { type = string }
variable "public_subnets" { type = list(string) }
variable "ssl_certificate_arn" { type = string }
variable "create_sg" { type = bool }
variable "existing_sg_id" { type = string }
variable "project_tags" { type = map(string) }

variable "ui_services" {
  type = map(object({
    container_port    = number
    health_check_path = string
    host_headers      = list(string)
    priority          = number
  }))
}