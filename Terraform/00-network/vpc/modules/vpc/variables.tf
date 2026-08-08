variable "create_vpc" {
  type        = bool
  description = "Set to true to build a new VPC. Set to false to use an existing VPC."
  default     = true
}

variable "existing_vpc_id" {
  type        = string
  description = "The ID of the existing VPC (Only required if create_vpc is false)."
  default     = ""
}

variable "vpc_name" { type = string }
variable "vpc_cidr" { type = string }
variable "aws_region" { type = string }

variable "nat_subnets" {
  type        = list(string)
  description = <<-EOT
    Availability zones that get their own NAT gateway. List every AZ for high
    availability: each private route table then egresses through the NAT in its own
    AZ, which removes the single point of failure and avoids cross-AZ data transfer
    charges. A shorter list still works (private subnets in AZs without a NAT fall
    back to the first one), but that is a cost tradeoff, not a supported HA posture.
  EOT

  validation {
    condition     = length(var.nat_subnets) > 0
    error_message = "nat_subnets must list at least one availability zone."
  }
}

# ---------------------------------------------------------------------------
# Subnet tiers
#
# Four tiers, each a list of {name, az, cidr}. Public routes via the internet
# gateway; every other tier routes via the NAT gateway in its own AZ.
#
# The eks tier is deliberately sized larger than the others because the VPC CNI
# assigns a real VPC IP address to every pod, not just every node.
# ---------------------------------------------------------------------------

variable "public_subnets" {
  type = list(object({
    name = string
    az   = string
    cidr = string
  }))
  description = "Internet-facing tier: load balancers and NAT gateways."
}

variable "private_subnets" {
  type = list(object({
    name = string
    az   = string
    cidr = string
  }))
  description = "Private application tier: ECS container instances."
}

variable "eks_subnets" {
  type = list(object({
    name = string
    az   = string
    cidr = string
  }))
  default     = []
  description = "Private EKS tier: worker nodes and pod ENIs."
}

variable "data_subnets" {
  type = list(object({
    name = string
    az   = string
    cidr = string
  }))
  default     = []
  description = "Private data tier: RDS, ElastiCache, Amazon MQ, OpenSearch."
}

variable "map_public_ip_on_launch" {
  type        = bool
  default     = false
  description = <<-EOT
    Auto-assign public IPs in the public tier. Defaults to false: NAT gateways use
    Elastic IPs and load balancers manage their own addresses, so nothing in this
    tier needs an automatic public IP. Leaving it false also clears Trivy AWS-0164.
  EOT
}

variable "enable_flow_logs" {
  type        = bool
  default     = true
  description = "Publish VPC flow logs to CloudWatch Logs."
}

variable "flow_log_retention_days" {
  type        = number
  default     = 90
  description = "Retention for the VPC flow log group."
}

variable "flow_log_kms_key_arn" {
  type        = string
  default     = ""
  description = "Customer-managed KMS key for the flow log group. Empty uses the CloudWatch Logs service key."
}

variable "project_tags" {
  type        = map(string)
  default     = {}
  description = "Tags merged onto every resource in this module."
}
