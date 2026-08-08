terraform {
  backend "s3" {
    bucket         = "plat-test-terraform-state"
    key            = "test/rabbitmq-backup/terraform.tfstate"
    region         = "ap-southeast-1"
    dynamodb_table = "terraform-state-locking"
    encrypt        = true
  }
}
