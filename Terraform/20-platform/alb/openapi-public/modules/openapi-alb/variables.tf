variable "environment" { type = string }
variable "vpc_id" { type = string }
variable "private_subnets" { type = list(string) }
variable "vpc_cidr_block" { type = string }

# Use the exact ALB name (no automatic suffix) to stay within AWS 32-char ALB name limit.
variable "alb_name" { type = string }

variable "alb_services" {
  description = "Map of service names to their configuration objects"
  type = map(object({
    container_port    = number
    health_check_path = string
  }))
}

variable "project_tags" {
  description = "Default tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "create_public_alb_rules" {
  description = "When true, create public ALB target groups and host-header listener rules for OpenAPI services"
  type        = bool
  default     = false
}

variable "public_alb_https_listener_arn" {
  description = "Existing public ALB HTTPS listener ARN where host rules will be attached"
  type        = string
  default     = ""
}

variable "public_tg_name_prefix" {
  description = "Prefix for public ALB target groups, e.g., plat-prod"
  type        = string
  default     = ""
}

variable "public_domain" {
  description = "Base public domain used for host rules"
  type        = string
  default     = "example.com"
}

variable "public_rule_priority_start" {
  description = "Starting priority for generated public ALB listener rules"
  type        = number
  default     = 30000
}
