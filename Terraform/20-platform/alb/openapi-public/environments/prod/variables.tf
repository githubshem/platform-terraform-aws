variable "environment" { type = string }
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
  description = "When true, create public ALB target groups and host rules"
  type        = bool
  default     = false
}

variable "public_alb_https_listener_arn" {
  description = "Existing public ALB HTTPS listener ARN"
  type        = string
  default     = ""
}

variable "public_tg_name_prefix" {
  description = "Prefix for public target group names"
  type        = string
  default     = ""
}

variable "public_domain" {
  description = "Base domain for host-based rules"
  type        = string
  default     = "example.com"
}

variable "public_rule_priority_start" {
  description = "Starting priority for generated public ALB host rules"
  type        = number
  default     = 30000
}
