# terraform.tfvars - test
aws_region     = "ap-southeast-1"
s3_bucket_name = "plat-test-rabbitmq-definitions-backup"

amazon_mq_broker_id    = "b-REPLACE_ME"
amazon_mq_secret_name  = "REPLACE_ME"
amazon_mq_username_key = "username"
amazon_mq_password_key = "password"

ecs_cluster_name = "plat-test-ecs-rmq"
ecs_mgmt_host    = "http://internal-REPLACE_lb.example.com:15672"
ecs_secret_name  = "REPLACE_ME"
ecs_username_key = "username"
ecs_password_key = "password"

tags = {
  Environment = "test"
  ManagedBy   = "terraform"
  Project     = "rabbitmq-s3-backup"
  Team        = "engineering"
}
