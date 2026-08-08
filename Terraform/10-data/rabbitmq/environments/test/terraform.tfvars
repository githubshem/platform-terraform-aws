environment        = "test"
broker_name        = "plat-test-hera-rmq-cluster"
engine_version     = "3.13"
host_instance_type = "mq.m7g.medium"
deployment_mode    = "CLUSTER_MULTI_AZ"

# Mirrors the existing broker settings so an import plans clean.
auto_minor_version_upgrade = true
enable_general_logs        = false
manage_default_tags        = false

kms_key_id             = "arn:aws:kms:ap-southeast-1:123456789012:key/99999999-8888-7777-6666-555555555555"
configuration_id       = "c-00000000-0000-0000-0000-000000000001"
configuration_revision = 1

# Admin credentials are read from Secrets Manager (no plaintext here).
admin_secret_name  = "test-ssm/hera/credentials"
admin_username_key = "rabbitmq-hera-rmq-cluster-username"
admin_password_key = "rabbitmq-hera-rmq-cluster-pwd"

maintenance_day  = "TUESDAY"
maintenance_time = "19:00"

# Live broker currently has NO tags. Kept empty to avoid any change on import.
# To start tagging, set manage_default_tags = true and/or populate this map in a
# deliberate apply.
project_tags = {}
