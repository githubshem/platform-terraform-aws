# Network identifiers come from the VPC and security-group stacks. The EKS
# subnet tier and eks_nodes security group have existed since the network
# rebuild with nothing attached to them; this is what consumes them.
data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = "plat-prod-terraform-state"
    key    = "prod/vpc/terraform.tfstate"
    region = "ap-southeast-1"
  }
}

data "terraform_remote_state" "security_groups" {
  backend = "s3"

  config = {
    bucket = "plat-prod-terraform-state"
    key    = "prod/security-groups/terraform.tfstate"
    region = "ap-southeast-1"
  }
}

module "eks" {
  source = "../../../../../modules/eks-cluster"

  cluster_name       = var.cluster_name
  name_prefix        = var.cluster_name
  kubernetes_version = var.kubernetes_version

  subnet_ids                 = data.terraform_remote_state.vpc.outputs.eks_subnet_ids
  cluster_security_group_ids = [data.terraform_remote_state.security_groups.outputs.eks_nodes_sg_id]

  kms_key_arn = var.kms_key_arn
  node_groups = var.node_groups
  tags        = var.project_tags
}
