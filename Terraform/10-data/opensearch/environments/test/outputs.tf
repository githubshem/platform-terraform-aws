# Consumed by the ism/ workspace, which configures the opensearch provider from
# these. A provider block cannot depend on a resource created in the same apply,
# which is why index lifecycle management lives in its own workspace.
output "domain_endpoint" {
  description = "VPC endpoint of the OpenSearch domain (no scheme)."
  value       = module.opensearch.domain_endpoint
}

output "domain_id" {
  description = "OpenSearch domain id."
  value       = module.opensearch.domain_id
}

output "security_group_id" {
  description = "Security group attached to the domain's ENIs."
  value       = module.opensearch.security_group_id
}
