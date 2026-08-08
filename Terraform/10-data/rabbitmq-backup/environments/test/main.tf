module "amazon_mq_backup" {
  source = "../../modules/rabbitmq-s3-backup"

  environment         = "test"
  broker_type         = "amazon_mq"
  broker_name         = "plat-test-amazon-mq"
  aws_region          = var.aws_region
  amazon_mq_broker_id = var.amazon_mq_broker_id

  s3_bucket_name = var.s3_bucket_name
  s3_prefix      = "rabbitmq-definitions"

  secret_name  = var.amazon_mq_secret_name
  username_key = var.amazon_mq_username_key
  password_key = var.amazon_mq_password_key

  backup_schedule = "cron(0 2 * * ? *)"
  retention_days  = 90

  tags = var.tags
}

module "ecs_rabbitmq_backup" {
  source = "../../modules/rabbitmq-s3-backup"

  environment = "test"
  broker_type = "ecs"
  broker_name = var.ecs_cluster_name
  aws_region  = var.aws_region
  mgmt_host   = var.ecs_mgmt_host

  s3_bucket_name = var.s3_bucket_name
  s3_prefix      = "rabbitmq-definitions"

  secret_name  = var.ecs_secret_name
  username_key = var.ecs_username_key
  password_key = var.ecs_password_key

  backup_schedule = "cron(0 2 * * ? *)"
  retention_days  = 90

  tags = var.tags
}
