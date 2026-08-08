variable "cluster_name" {
  description = "Name of the EKS cluster, e.g. plat-prod-zeus."
  type        = string
}

variable "name_prefix" {
  description = "Prefix for IAM role names, e.g. plat-prod-zeus."
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes minor version for the control plane."
  type        = string
}

variable "subnet_ids" {
  description = "EKS-tier subnet IDs from the VPC stack. These are the /19 subnets sized for one IP per pod."
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "EKS requires subnets in at least two availability zones."
  }
}

variable "cluster_security_group_ids" {
  description = "Additional security groups for the control plane ENIs."
  type        = list(string)
  default     = []
}

variable "endpoint_public_access" {
  description = "Whether the Kubernetes API is reachable from the internet. Private access is always on."
  type        = bool
  default     = false
}

variable "public_access_cidrs" {
  description = "CIDRs allowed to reach a public API endpoint. Ignored unless endpoint_public_access is true."
  type        = list(string)
  default     = []

  validation {
    condition     = !contains(var.public_access_cidrs, "0.0.0.0/0")
    error_message = "Do not expose the Kubernetes API to 0.0.0.0/0."
  }
}

variable "kms_key_arn" {
  description = "KMS key used to envelope-encrypt Kubernetes secrets at rest."
  type        = string
}

variable "enabled_cluster_log_types" {
  description = "Control plane log types sent to CloudWatch. audit and authenticator are what you need after a security incident."
  type        = list(string)
  default     = ["api", "audit", "authenticator"]
}

variable "node_groups" {
  description = <<-EOT
    Managed node groups, keyed by name. desired_size is the initial value only:
    the module ignores later changes so the cluster autoscaler can own it.
  EOT
  type = map(object({
    instance_types = list(string)
    capacity_type  = optional(string, "ON_DEMAND")
    disk_size      = optional(number, 50)
    desired_size   = number
    min_size       = number
    max_size       = number
    labels         = optional(map(string), {})
    taints = optional(list(object({
      key    = string
      value  = string
      effect = string
    })), [])
  }))
}

variable "addons" {
  description = "EKS addons keyed by name. Leave version null to take the default for the cluster version."
  type = map(object({
    version                  = optional(string)
    service_account_role_arn = optional(string)
  }))
  default = {
    vpc-cni    = {}
    coredns    = {}
    kube-proxy = {}
  }
}

variable "tags" {
  description = "Tags applied to all resources in this module."
  type        = map(string)
  default     = {}
}
