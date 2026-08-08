variable "aws_region" { type = string }
variable "project_name" { type = string }
variable "environment" { type = string }
variable "instance_type" { type = string }
variable "vpc_name" { type = string }
variable "vpc_id" { type = string }

variable "public_subnet_ids" {
  description = "Public subnet IDs from the VPC stack, sorted by AZ."
  type        = list(string)
}


variable "state_buckets" {
  description = "Live Terraform state buckets the backup job reads. Read-only for this role."
  type        = list(string)
}

variable "state_backup_bucket" {
  description = "Destination bucket for the daily state mirror. Write-only for this role."
  type        = string
}

variable "rabbitmq_backup_bucket" {
  description = "Destination bucket for RabbitMQ definition exports. Write-only for this role."
  type        = string
}

variable "jenkins_ui_allowed_cidrs" {
  description = <<-EOT
    CIDRs allowed to reach the Jenkins UI on 8080. No default on purpose: this
    was previously open to 0.0.0.0/0, and a default would let that reappear by
    omission. Administration does not need this -- use SSM port forwarding.
  EOT
  type        = list(string)

  validation {
    condition     = !contains(var.jenkins_ui_allowed_cidrs, "0.0.0.0/0")
    error_message = "The Jenkins UI must not be exposed to 0.0.0.0/0. Use SSM port forwarding, or list specific VPN/office CIDRs."
  }
}
