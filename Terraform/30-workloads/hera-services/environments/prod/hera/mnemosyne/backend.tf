terraform {
  backend "s3" {
    bucket         = "plat-prod-terraform-state"
    key            = "prod/hera-services/mnemosyne/terraform.tfstate"
    region         = "ap-southeast-1"
    dynamodb_table = "terraform-state-locking"
    encrypt        = true
  }
}
