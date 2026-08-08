terraform {
  backend "s3" {
    bucket         = "plat-test-terraform-state"
    key            = "test/hera-services/plutus/terraform.tfstate"
    region         = "ap-southeast-1"
    dynamodb_table = "terraform-state-locking"
    encrypt        = true
  }
}
