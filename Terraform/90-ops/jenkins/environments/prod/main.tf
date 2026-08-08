# Network identifiers come from the VPC stack rather than hardcoded values.
data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = "plat-prod-terraform-state"
    key    = "prod/vpc/terraform.tfstate"
    region = "ap-southeast-1"
  }
}

module "jenkins" {
  source = "../../modules/jenkins"

  aws_region    = var.aws_region
  project_name  = var.project_name
  environment   = var.environment
  instance_type = var.instance_type
  vpc_name      = var.vpc_name
  vpc_id        = data.terraform_remote_state.vpc.outputs.vpc_id

  # Sorted by AZ, so the controller keeps the same subnet across applies. The
  # module used to discover this with a tag wildcard and take ids[0], which AWS
  # returns in no guaranteed order.
  public_subnet_ids = data.terraform_remote_state.vpc.outputs.public_subnet_ids

  # Buckets the scheduled backup jobs touch. Read and write are separate lists so
  # the role can never write to live state.
  state_buckets          = var.state_buckets
  state_backup_bucket    = var.state_backup_bucket
  rabbitmq_backup_bucket = var.rabbitmq_backup_bucket

  # In-VPC callers are always allowed; anything else has to be listed
  # explicitly. Reaching the UI from outside without widening this is what SSM
  # port forwarding is for:
  #   aws ssm start-session --target <id>   #     --document-name AWS-StartPortForwardingSession   #     --parameters '{"portNumber":["8080"],"localPortNumber":["8080"]}'
  jenkins_ui_allowed_cidrs = concat(
    [data.terraform_remote_state.vpc.outputs.vpc_cidr],
    var.jenkins_ui_extra_allowed_cidrs,
  )
}
