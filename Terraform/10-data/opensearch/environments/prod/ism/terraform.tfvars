# Index lifecycle management for the logging indices.
#
# Applied by the ism/ workspace, which must run from inside the VPC: the
# domain has no public endpoint. See providers.tf.

aws_region                  = "ap-southeast-1"
master_user_name            = "admin"
master_password_secret_name = "prod/opensearch/tf-os-master-password"

ism_policy_id        = "plat-prod-retention-policy"
index_template_name  = "plat-prod-logging-template"
bootstrap_index_name = "plat-logs-prod-000001"
rollover_alias       = "plat-logs-prod"

ism_policy_body = <<-POLICY
{
  "policy": {
    "description": "Unified rollover and 14-day retention policy.",
    "default_state": "hot",
    "states": [
      {
        "name": "hot",
        "actions": [],
        "transitions": [
          { "state_name": "delete", "conditions": { "min_index_age": "14d" } }
        ]
      },
      {
        "name": "delete",
        "actions": [ { "retry": { "count": 3, "backoff": "exponential", "delay": "1m" }, "delete": {} } ],
        "transitions": []
      }
    ],
    "ism_template": [ { "index_patterns": ["plat-logs-prod-*"], "priority": 100 } ]
  }
}
POLICY

index_template_body = <<-TEMPLATE
{
  "index_patterns": ["plat-logs-prod-*"],
  "template": {
    "settings": {
      "index": {
        "number_of_shards": 3,
        "number_of_replicas": 1,
        "plugins.index_state_management.rollover_alias": "plat-logs-prod"
      }
    }
  }
}
TEMPLATE

project_tags = {
  Environment = "prod"
  Project     = "plat-opensearch"
  ManagedBy   = "terraform"
}
