variable "aws_region" {
  description = "Region hosting the OpenSearch domain."
  type        = string
}

variable "master_user_name" {
  description = "OpenSearch master user for the internal user database."
  type        = string
}

variable "master_password_secret_name" {
  description = "Secrets Manager secret holding the master user password."
  type        = string
}

variable "ism_policy_id" {
  description = "Identifier of the ISM policy in OpenSearch."
  type        = string
}

variable "ism_policy_body" {
  description = "ISM policy document (JSON)."
  type        = string
}

variable "index_template_name" {
  description = "Name of the composable index template."
  type        = string
}

variable "index_template_body" {
  description = "Composable index template document (JSON)."
  type        = string
}

variable "bootstrap_index_name" {
  description = "First concrete index, carrying the write alias."
  type        = string
}

variable "rollover_alias" {
  description = "Write alias ISM rolls over."
  type        = string
}

variable "project_tags" {
  description = "Tags applied via provider default_tags."
  type        = map(string)
}
