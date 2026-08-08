terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    opensearch = {
      source  = "opensearch-project/opensearch"
      version = "~> 2.3"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = var.project_tags
  }
}

# The domain is VPC-internal with no public endpoint, so this provider only
# resolves and connects from inside the VPC. Run this workspace from a Jenkins
# agent in a private subnet; it will hang and time out from a laptop.
#
# The endpoint comes from the domain stack's state rather than a resource here,
# because a provider block cannot depend on a resource created in the same apply.
provider "opensearch" {
  url      = "https://${data.terraform_remote_state.opensearch.outputs.domain_endpoint}"
  username = var.master_user_name
  password = data.aws_secretsmanager_secret_version.os_password.secret_string

  # Basic auth against the internal user database, not SigV4.
  sign_aws_requests = false

  # The provider's healthcheck hits / on the domain, which the restrictive
  # access policy rejects even when the credentials are good.
  healthcheck = false
}
