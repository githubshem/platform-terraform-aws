variable "ism_policy_id" {
  description = "Identifier of the ISM policy in OpenSearch."
  type        = string
}

variable "ism_policy_body" {
  description = "ISM policy document (JSON). Its ism_template.index_patterns must match the indices this environment actually writes, or the policy attaches to nothing."
  type        = string
}

variable "index_template_name" {
  description = "Name of the composable index template."
  type        = string
}

variable "index_template_body" {
  description = "Composable index template document (JSON): top-level index_patterns with a nested template block."
  type        = string
}

variable "bootstrap_index_name" {
  description = "First concrete index, e.g. plat-logs-prod-000001. Carries the write alias so ISM has something to roll over."
  type        = string
}

variable "rollover_alias" {
  description = "Write alias ISM rolls over, e.g. plat-logs-prod."
  type        = string
}

variable "bootstrap_number_of_shards" {
  description = "Shard count for the bootstrap index. Should match the index template so the first index is not an outlier."
  type        = number
  default     = 3
}

variable "bootstrap_number_of_replicas" {
  description = "Replica count for the bootstrap index."
  type        = number
  default     = 1
}
