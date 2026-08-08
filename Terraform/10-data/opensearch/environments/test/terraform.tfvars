aws_region          = "ap-southeast-1"
allowed_cidr_blocks = ["10.9.0.0/16", "172.31.0.0/16"]

domain_name = "plat-test"

#datanode configuration
instance_type  = "m7g.large.search"
instance_count = 3

# Multi-AZ. The module derives availability_zone_count from the number of data
# subnets (3), so instance_count MUST be a multiple of 3 or the AWS API rejects
# the domain. This was single-AZ with 2 nodes, which for a domain that now carries
# ISM-managed application logging means one AZ event takes logging down.
zone_awareness_enabled   = true
dedicated_master_enabled = true
#master
master_instance_type  = "m7g.medium.search"
master_instance_count = 3

ebs_enabled     = true
ebs_volume_size = 200
ebs_volume_type = "gp3"
ebs_iops        = 3000
ebs_throughput  = 250

kms_key_arn      = "arn:aws:kms:ap-southeast-1:123456789012:key/aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"
master_user_name = "aws-admin"
snapshot_hour    = 0

project_tags = {
  Environment = "test"
  Project     = "plat-test"
  ManagedBy   = "terraform"
}

# 1. AWS VPC Access Policy
access_policies = <<-POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": { "AWS": "*" },
      "Action": "es:*",
      "Resource": "arn:aws:es:ap-southeast-1:123456789012:domain/plat-prod-test/*"
    }
  ]
}
POLICY
