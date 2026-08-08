aws_region         = "ap-southeast-1"
cluster_name       = "plat-prod-zeus"
kubernetes_version = "1.31"

# Envelope encryption for Kubernetes secrets. Must be a real key in this account
# and region before the first apply; EKS cannot create it.
kms_key_arn = "arn:aws:kms:ap-southeast-1:123456789012:key/aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"

# Two pools. The system pool is tainted so cluster-critical workloads (CoreDNS,
# controllers, Fluent Bit) keep capacity when the app pool is saturated or
# scaled to zero -- without the taint an app burst can evict them.
#
# r7i.large matches what the ECS nodes run today, so moving a service between
# ECS and EKS does not silently change its hardware underneath it.
node_groups = {
  system = {
    instance_types = ["m7i.large"]
    desired_size   = 3
    min_size       = 3
    max_size       = 5
    labels         = { pool = "system" }
    taints = [{
      key    = "CriticalAddonsOnly"
      value  = "true"
      effect = "NO_SCHEDULE"
    }]
  }

  apps = {
    instance_types = ["r7i.large"]
    desired_size   = 6
    min_size       = 3
    max_size       = 20
    labels         = { pool = "apps" }
  }
}

project_tags = {
  Environment = "prod"
  Project     = "plat-zeus-eks"
  ManagedBy   = "terraform"
}
