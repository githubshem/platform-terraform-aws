module "ecs_cluster" {
  source                       = "../backend-cluster"
  app_prefix                   = var.app_prefix
  environment                  = var.environment
  cluster_name                 = var.cluster_name
  ami_id                       = var.ami_id
  security_group_ids           = var.service_security_group_ids
  container_insights           = var.container_insights
  ec2_instance_type            = var.ec2_instance_type
  private_subnets              = var.private_subnets
  service_security_group_ids   = var.service_security_group_ids
  min_size                     = var.min_size
  max_size                     = var.max_size
  ecs_instance_profile_name    = var.ecs_instance_profile_name
  target_capacity              = var.target_capacity
  default_cp_weight            = var.default_cp_weight
  warm_pool_size               = var.warm_pool_size
  dedicated_capacity_providers = var.dedicated_capacity_providers
  tags                         = var.project_tags
  ec2_key_name                 = var.ec2_key_name
}

module "ecs_services" {
  source     = "../backend-service"
  app_prefix = var.app_prefix
  for_each   = var.microservices

  environment  = var.environment
  aws_region   = var.aws_region
  cluster_name = module.ecs_cluster.cluster_name
  cluster_id   = module.ecs_cluster.cluster_id

  service_name     = each.key
  compute_type     = each.value.launch_type
  compute_provider = each.value.provider == "EC2_DYNAMIC" ? module.ecs_cluster.ec2_capacity_provider : each.value.provider

  cpu        = each.value.cpu
  memory     = each.value.memory
  task_count = each.value.count
  port       = each.value.port
  image_url  = each.value.image

  private_subnets    = var.private_subnets
  security_group_id  = var.service_security_group_ids
  execution_role_arn = var.ecs_execution_role_arn
  task_role_arn      = var.ecs_task_role_arn
  target_group_arn   = each.value.target_group_arn
  # NEW: Global overrides passed from tfvars
  cloudwatch_retention_days = var.cloudwatch_retention_days
  placement_strategy_type   = var.placement_strategy_type
  placement_strategy_field  = var.placement_strategy_field

  # NEW: Granular Service-Level overrides (with safe defaults)
  cp_weight          = lookup(each.value, "cp_weight", 100)
  max_capacity       = lookup(each.value, "max_capacity", 10)
  cpu_target_value   = lookup(each.value, "cpu_target_value", 65.0)
  scale_out_cooldown = lookup(each.value, "scale_out_cooldown", 180)
  scale_in_cooldown  = lookup(each.value, "scale_in_cooldown", 240)
  memory_reservation = each.value.memory_reservation
  host_volume_name   = each.value.host_volume_name
  host_volume_path   = each.value.host_volume_path
  env_vars           = each.value.env_vars
  capacity_provider  = lookup(each.value, "capacity_provider", "")
}