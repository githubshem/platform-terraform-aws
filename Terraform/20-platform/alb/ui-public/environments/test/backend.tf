# The key still says frontend-portals while the folder is ui-public. That is
# deliberate: state keys are decoupled from paths so folders can be renamed
# without terraform state mv. Changing it means moving the S3 object, which is
# a state-affecting operation and not part of a rename.
terraform {
  backend "s3" {
    bucket         = "plat-test-terraform-state"
    key            = "test/frontend-portals/terraform.tfstate"
    region         = "ap-southeast-1"
    dynamodb_table = "terraform-state-locking"
    encrypt        = true
  }
}
