terraform {
  required_version = ">= 1.5.0"

  required_providers {
    opensearch = {
      source  = "opensearch-project/opensearch"
      version = "~> 2.3"
    }
  }
}
