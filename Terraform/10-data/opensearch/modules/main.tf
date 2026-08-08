terraform {
  required_providers {
    opensearch = {
      source  = "opensearch-project/opensearch"
      version = "~> 2.2.0"
    }
  }
}

resource "aws_security_group" "opensearch_sg" {
  name        = "${var.domain_name}-sg"
  description = "Allow HTTPS traffic to OpenSearch"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.domain_name}-sg" })
}

resource "aws_opensearch_domain" "this" {
  domain_name    = var.domain_name
  engine_version = "OpenSearch_2.7"

  cluster_config {
    instance_type  = var.instance_type
    instance_count = var.instance_count

    # Now fully dynamic based on your tfvars
    zone_awareness_enabled   = var.zone_awareness_enabled
    dedicated_master_enabled = var.dedicated_master_enabled

    # Only pass master details if masters are actually enabled
    dedicated_master_type  = var.dedicated_master_enabled ? var.master_instance_type : null
    dedicated_master_count = var.dedicated_master_enabled ? var.master_instance_count : null

    # Only build the zone config if Multi-AZ is true
    dynamic "zone_awareness_config" {
      for_each = var.zone_awareness_enabled ? [1] : []
      content {
        availability_zone_count = length(var.subnet_ids)
      }
    }
  }

  vpc_options {
    subnet_ids         = var.subnet_ids
    security_group_ids = [aws_security_group.opensearch_sg.id]
  }

  ebs_options {
    ebs_enabled = var.ebs_enabled
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_iops
    throughput  = var.ebs_throughput
  }

  access_policies = var.access_policies

  encrypt_at_rest {
    enabled    = true
    kms_key_id = var.kms_key_arn
  }

  node_to_node_encryption {
    enabled = true
  }

  domain_endpoint_options {
    enforce_https           = true
    custom_endpoint_enabled = false
    tls_security_policy     = "Policy-Min-TLS-1-2-2019-07"
  }

  advanced_security_options {
    enabled                        = true
    internal_user_database_enabled = true

    master_user_options {
      master_user_name     = var.master_user_name
      master_user_password = var.master_user_password
    }
  }

  snapshot_options {
    automated_snapshot_start_hour = var.snapshot_hour
  }

  tags = var.tags
}

# AWS rejects the domain with an opaque API error if data nodes do not divide
# evenly across AZs. Catching it at plan time says which number is wrong.
check "zone_awareness_instance_count" {
  assert {
    condition = !var.zone_awareness_enabled || (
      var.instance_count % length(var.subnet_ids) == 0
    )
    error_message = format(
      "zone_awareness_enabled is true with %d subnets, so instance_count must be a multiple of %d (got %d).",
      length(var.subnet_ids), length(var.subnet_ids), var.instance_count,
    )
  }
  assert {
    condition     = !var.dedicated_master_enabled || var.master_instance_count == 3
    error_message = "Dedicated masters need exactly 3 for a quorum; 1 has no redundancy and 2 cannot elect."
  }
}
