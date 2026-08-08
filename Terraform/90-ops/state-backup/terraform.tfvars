aws_region          = "ap-southeast-1"
source_state_bucket = "plat-test-terraform-state"
backup_bucket_name  = "plat-terraform-state-backup"

# Superseded versions age out after 180 days; current versions are kept forever.
noncurrent_version_retention_days = 180

project_tag = "terraform-state-backup"
tags        = {}
