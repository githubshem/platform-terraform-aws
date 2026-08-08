aws_region = "ap-southeast-1"

# Dynamic Subnets & CIDRs instead of hardcoding inside the module
allowed_cidr_blocks = ["10.10.0.0/16"]

domain_name = "plat-prod-dev"
#instance_type        = "m7g.large.search"
#instance_count       = 2

#datanode configuration
instance_type  = "m7g.large.search"
instance_count = 3

# Multi-AZ. The module derives availability_zone_count from the number of data
# subnets (3), so instance_count MUST be a multiple of 3 or the AWS API rejects
# the domain. This was single-AZ with 2 nodes, which for a domain that now carries
# ISM-managed application logging means one AZ event takes logging down.
#
# Dedicated masters are separate from data nodes so cluster state survives a data
# node being saturated. Three is the minimum for a quorum -- two cannot elect.
master_instance_type     = "m7g.large.search"
master_instance_count    = 3
zone_awareness_enabled   = true
dedicated_master_enabled = true

ebs_enabled     = true
ebs_volume_size = 200
ebs_volume_type = "gp3"
ebs_iops        = 3000
ebs_throughput  = 250

kms_key_arn      = "arn:aws:kms:ap-southeast-1:123456789012:key/aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"
master_user_name = "admin"
#master_user_password = "!"
snapshot_hour = 0

access_policies = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": { "AWS": "*" },
      "Action": "es:*",
      "Resource": "*"
    }
  ]
}
POLICY

project_tags = {
  Environment = "prod"
  Project     = "plat-prod"
  ManagedBy   = "terraform"
}
