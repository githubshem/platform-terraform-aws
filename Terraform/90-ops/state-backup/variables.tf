variable "aws_region" {
  description = "AWS region where the backup bucket is created"
  type        = string
  default     = "ap-southeast-1"
}

variable "source_state_buckets" {
  description = <<-EOT
    The live Terraform state buckets being backed up. Read-only reference: these
    are not managed here, and nothing in this stack consumes the value. It exists
    so the backup bucket's purpose is readable from its own configuration.
    State is isolated per environment, so this must list both.
  EOT
  type        = list(string)
  default     = ["plat-test-terraform-state", "plat-prod-terraform-state"]
}

variable "backup_bucket_name" {
  description = "Name of the dedicated S3 bucket that stores Terraform state backups"
  type        = string
  default     = "plat-terraform-state-backup"
}

variable "noncurrent_version_retention_days" {
  description = "Days to keep superseded (noncurrent) object versions before they expire. Current versions are never auto-expired by age, since infrequently-changed state files must not be deleted just because they haven't been re-synced recently."
  type        = number
  default     = 180

  validation {
    condition     = var.noncurrent_version_retention_days >= 1
    error_message = "noncurrent_version_retention_days must be at least 1."
  }
}

variable "project_tag" {
  description = "Ticket/project identifier applied as a Project tag on all resources"
  type        = string
  default     = "terraform-state-backup"
}

variable "tags" {
  description = "Additional tags to merge onto all resources"
  type        = map(string)
  default     = {}
}
