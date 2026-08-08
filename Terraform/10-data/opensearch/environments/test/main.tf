# Network identifiers come from the VPC and security-group stacks rather than
# hardcoded values, so a subnet or SG replacement propagates on the next apply.
data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = "plat-test-terraform-state"
    key    = "test/vpc/terraform.tfstate"
    region = "ap-southeast-1"
  }
}

data "terraform_remote_state" "security_groups" {
  backend = "s3"

  config = {
    bucket = "plat-test-terraform-state"
    key    = "test/security-groups/terraform.tfstate"
    region = "ap-southeast-1"
  }
}

data "aws_secretsmanager_secret" "os_password" {
  name = "test/opensearch/tf-os-master-password"
}

data "aws_secretsmanager_secret_version" "os_password" {
  secret_id = data.aws_secretsmanager_secret.os_password.id
}

module "opensearch" {
  source = "../../modules"

  domain_name         = var.domain_name
  vpc_id              = data.terraform_remote_state.vpc.outputs.vpc_id
  subnet_ids          = data.terraform_remote_state.vpc.outputs.data_subnet_ids
  allowed_cidr_blocks = var.allowed_cidr_blocks

  instance_type            = var.instance_type
  instance_count           = var.instance_count
  master_instance_type     = var.master_instance_type
  master_instance_count    = var.master_instance_count
  zone_awareness_enabled   = var.zone_awareness_enabled
  dedicated_master_enabled = var.dedicated_master_enabled

  ebs_enabled     = var.ebs_enabled
  ebs_volume_size = var.ebs_volume_size
  ebs_volume_type = var.ebs_volume_type
  ebs_iops        = var.ebs_iops
  ebs_throughput  = var.ebs_throughput

  kms_key_arn          = var.kms_key_arn
  master_user_name     = var.master_user_name
  master_user_password = data.aws_secretsmanager_secret_version.os_password.secret_string
  snapshot_hour        = var.snapshot_hour

  access_policies = var.access_policies
  tags            = var.project_tags
}