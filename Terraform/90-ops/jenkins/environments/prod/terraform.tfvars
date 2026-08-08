aws_region    = "ap-southeast-1"
project_name  = "plat-prod"
environment   = "prod"
vpc_name      = "plat-prod-vpc-apse1"
instance_type = "t3.medium"

project_tags = {
  Environment = "prod"
  Project     = "plat-jenkins"
  ManagedBy   = "terraform"
}

# Must match SOURCE_BUCKETS / DEST_BUCKET in Jenkinsfile.terraform-state-backup
# and S3_BUCKET in Jenkinsfile.rabbitmq-backup.
state_buckets          = ["plat-test-terraform-state", "plat-prod-terraform-state"]
state_backup_bucket    = "plat-terraform-state-backup"
rabbitmq_backup_bucket = "plat-prod-rabbitmq-definitions-backup"

# The VPC CIDR is allowed automatically. Add an office or VPN range here only if
# someone needs the UI without SSM port forwarding; 0.0.0.0/0 is rejected by a
# variable validation in the module.
jenkins_ui_extra_allowed_cidrs = []
