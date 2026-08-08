terraform {
  backend "s3" {
    bucket         = "plat-prod-terraform-state"
    key            = "prod/hera-services/notus/terraform.tfstate"
    region         = "ap-southeast-1"
    dynamodb_table = "terraform-state-locking"
    encrypt        = true
  }
}
