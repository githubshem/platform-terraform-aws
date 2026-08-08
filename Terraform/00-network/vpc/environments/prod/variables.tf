# ==========================================
# ROOT LAYER VARIABLE DECLARATIONS
# ==========================================

variable "create_vpc" {
  type        = bool
  description = "Set to true to build a new VPC. Set to false to use an existing VPC."
  default     = true
}

variable "existing_vpc_id" {
  type        = string
  description = "The ID of the existing VPC (only required if create_vpc is false)."
  default     = ""
}

variable "vpc_name" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "nat_subnets" {
  type        = list(string)
  description = "Availability zones that get their own NAT gateway. List every AZ for HA."
}

variable "public_subnets" {
  type = list(object({
    name = string
    az   = string
    cidr = string
  }))
}

variable "private_subnets" {
  type = list(object({
    name = string
    az   = string
    cidr = string
  }))
}

variable "eks_subnets" {
  type = list(object({
    name = string
    az   = string
    cidr = string
  }))
  default = []
}

variable "data_subnets" {
  type = list(object({
    name = string
    az   = string
    cidr = string
  }))
  default = []
}

variable "enable_flow_logs" {
  type    = bool
  default = true
}

variable "flow_log_retention_days" {
  type    = number
  default = 90
}

variable "project_tags" {
  type    = map(string)
  default = {}
}
