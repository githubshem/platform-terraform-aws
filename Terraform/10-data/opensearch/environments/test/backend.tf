terraform {
  backend "s3" {
    bucket         = "plat-test-terraform-state"
    key            = "test/opensearch/terraform.tfstate"
    region         = "ap-southeast-1"
    dynamodb_table = "terraform-state-locking"
    encrypt        = true
  }
}
