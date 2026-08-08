variable "aws_region" {
  description = "Region hosting the cluster."
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name, also the IAM role name prefix."
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes minor version for the control plane."
  type        = string
}

variable "kms_key_arn" {
  description = "KMS key used to envelope-encrypt Kubernetes secrets."
  type        = string
}

variable "node_groups" {
  description = "Managed node groups for this cluster."
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

variable "project_tags" {
  description = "Tags applied via provider default_tags and to module resources."
  type        = map(string)
}
