# Endpoint and credentials for the opensearch provider. Reading the domain from
# remote state (rather than creating it here) is what lets the provider be
# configured at all -- see providers.tf.
data "terraform_remote_state" "opensearch" {
  backend = "s3"

  config = {
    bucket = "plat-prod-terraform-state"
    key    = "prod/opensearch/terraform.tfstate"
    region = "ap-southeast-1"
  }
}

data "aws_secretsmanager_secret" "os_password" {
  name = var.master_password_secret_name
}

data "aws_secretsmanager_secret_version" "os_password" {
  secret_id = data.aws_secretsmanager_secret.os_password.id
}

module "ism" {
  source = "../../../modules/ism"

  ism_policy_id        = var.ism_policy_id
  ism_policy_body      = var.ism_policy_body
  index_template_name  = var.index_template_name
  index_template_body  = var.index_template_body
  bootstrap_index_name = var.bootstrap_index_name
  rollover_alias       = var.rollover_alias
}
