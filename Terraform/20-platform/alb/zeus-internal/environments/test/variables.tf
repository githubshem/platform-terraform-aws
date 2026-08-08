variable "environment" { type = string }
variable "alb_name" { type = string }
variable "alb_services" {
  description = "Map of service names to their configuration objects"
  type = map(object({
    container_port    = number
    health_check_path = string
  }))
}

# Add the project_tags variable you referenced
variable "project_tags" {
  description = "Default tags to apply to all resources"
  type        = map(string)
  default     = {}
}