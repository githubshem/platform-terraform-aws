module "vpc" {
  source = "../../modules/vpc"

  create_vpc      = var.create_vpc
  existing_vpc_id = var.existing_vpc_id
  vpc_name        = var.vpc_name
  vpc_cidr        = var.vpc_cidr
  aws_region      = var.aws_region

  nat_subnets     = var.nat_subnets
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  eks_subnets     = var.eks_subnets
  data_subnets    = var.data_subnets

  enable_flow_logs        = var.enable_flow_logs
  flow_log_retention_days = var.flow_log_retention_days

  project_tags = var.project_tags
}
