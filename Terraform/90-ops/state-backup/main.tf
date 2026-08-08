################################################################################
# S3 Backup Bucket - destination only.
# The live state buckets (var.source_state_buckets) are NOT managed here and are
# never modified by this module; Jenkins only ever reads from them.
################################################################################

resource "aws_s3_bucket" "state_backup" {
  bucket        = var.backup_bucket_name
  force_destroy = false

  tags = merge(var.tags, {
    Name      = var.backup_bucket_name
    ManagedBy = "terraform"
    Project   = var.project_tag
  })
}

resource "aws_s3_bucket_versioning" "state_backup" {
  bucket = aws_s3_bucket.state_backup.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "state_backup" {
  bucket = aws_s3_bucket.state_backup.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "state_backup" {
  bucket = aws_s3_bucket.state_backup.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Only noncurrent (superseded) versions expire. Current versions are kept
# indefinitely - an infrequently-changed state file must not be deleted just
# because `aws s3 sync` hasn't touched it in a while.
resource "aws_s3_bucket_lifecycle_configuration" "state_backup" {
  bucket = aws_s3_bucket.state_backup.id

  rule {
    id     = "expire-noncurrent-versions"
    status = "Enabled"

    filter {}

    noncurrent_version_expiration {
      noncurrent_days = var.noncurrent_version_retention_days
    }
  }
}

data "aws_iam_policy_document" "state_backup" {
  statement {
    sid    = "DenyInsecureTransport"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = ["s3:*"]
    resources = [
      aws_s3_bucket.state_backup.arn,
      "${aws_s3_bucket.state_backup.arn}/*",
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_policy" "state_backup" {
  bucket = aws_s3_bucket.state_backup.id
  policy = data.aws_iam_policy_document.state_backup.json
}
