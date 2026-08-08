variable "environment" {
  type    = string
  default = "prod"
}

variable "broker_name" {
  type = string
}

variable "admin_secret_name" {
  description = "Secrets Manager secret holding the RabbitMQ admin credentials (JSON)"
  type        = string
}

variable "admin_username_key" {
  description = "JSON key in the secret for the admin username"
  type        = string
}

variable "admin_password_key" {
  description = "JSON key in the secret for the admin password"
  type        = string
}

variable "engine_version" {
  type    = string
  default = "3.13"
}

variable "auto_minor_version_upgrade" {
  type    = bool
  default = true
}

variable "enable_general_logs" {
  type    = bool
  default = true
}

variable "manage_default_tags" {
  type    = bool
  default = true
}

variable "kms_key_id" {
  type    = string
  default = ""
}

variable "configuration_id" {
  type    = string
  default = ""
}

variable "configuration_revision" {
  type    = number
  default = null
}

variable "host_instance_type" {
  type = string
}

variable "deployment_mode" {
  type    = string
  default = "CLUSTER_MULTI_AZ"
}

variable "maintenance_day" {
  type    = string
  default = "SUNDAY"
}

variable "maintenance_time" {
  type    = string
  default = "03:00"
}

variable "project_tags" {
  type    = map(string)
  default = {}
}
