variable "aws_region" {
  description = "Region hosting the Jenkins controller."
  type        = string
}

variable "project_name" {
  description = "Resource name prefix, e.g. plat-prod."
  type        = string
}

variable "environment" {
  description = "Environment this controller serves."
  type        = string
}

variable "vpc_name" {
  description = "Human-readable VPC name, used in resource naming and tags."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for the Jenkins controller."
  type        = string
}

variable "project_tags" {
  description = "Tags applied to every resource in this stack via provider default_tags."
  type        = map(string)
}

variable "state_buckets" {
  description = "Live Terraform state buckets the daily backup job reads."
  type        = list(string)
}

variable "state_backup_bucket" {
  description = "Destination bucket for the daily Terraform state mirror."
  type        = string
}

variable "rabbitmq_backup_bucket" {
  description = "Destination bucket for RabbitMQ definition exports."
  type        = string
}

variable "jenkins_ui_extra_allowed_cidrs" {
  description = "CIDRs outside the VPC allowed to reach the Jenkins UI, e.g. an office or VPN range. Empty means in-VPC only."
  type        = list(string)
  default     = []
}
