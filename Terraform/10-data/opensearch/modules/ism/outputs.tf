output "ism_policy_id" {
  description = "Identifier of the applied ISM policy."
  value       = opensearch_ism_policy.retention.policy_id
}

output "index_template_name" {
  description = "Name of the applied composable index template."
  value       = opensearch_composable_index_template.logging.name
}

output "bootstrap_index_name" {
  description = "Name of the bootstrap index holding the write alias."
  value       = opensearch_index.bootstrap.name
}
