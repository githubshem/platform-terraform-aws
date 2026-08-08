variable "aws_region" {
  type    = string
  default = "ap-southeast-1"
}

variable "s3_bucket_name" {
  type = string
}

variable "amazon_mq_broker_id" {
  type = string
}

variable "amazon_mq_secret_name" {
  type = string
}

variable "amazon_mq_username_key" {
  type = string
}

variable "amazon_mq_password_key" {
  type = string
}

variable "ecs_cluster_name" {
  type = string
}

variable "ecs_mgmt_host" {
  type = string
}

variable "ecs_secret_name" {
  type = string
}

variable "ecs_username_key" {
  type = string
}

variable "ecs_password_key" {
  type = string
}

variable "tags" {
  type = map(string)
  default = {
    Environment = "test"
    ManagedBy   = "terraform"
    Project     = "rabbitmq-s3-backup"
    Team        = "engineering"
  }
}
