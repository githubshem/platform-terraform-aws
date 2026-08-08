################################################################################
# S3 Backup Bucket
################################################################################

resource "aws_s3_bucket" "rabbitmq_backup" {
  bucket        = var.s3_bucket_name
  force_destroy = false

  tags = merge(var.tags, {
    Name        = var.s3_bucket_name
    Environment = var.environment
    ManagedBy   = "terraform"
    Project     = var.project_tag
  })
}

resource "aws_s3_bucket_versioning" "rabbitmq_backup" {
  bucket = aws_s3_bucket.rabbitmq_backup.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "rabbitmq_backup" {
  bucket = aws_s3_bucket.rabbitmq_backup.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "rabbitmq_backup" {
  bucket = aws_s3_bucket.rabbitmq_backup.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "rabbitmq_backup" {
  bucket = aws_s3_bucket.rabbitmq_backup.id

  rule {
    id     = "expire-old-backups"
    status = "Enabled"

    expiration {
      days = var.retention_days
    }

    noncurrent_version_expiration {
      noncurrent_days = var.retention_days
    }
  }
}

################################################################################
# CloudWatch Log Group
################################################################################

resource "aws_cloudwatch_log_group" "backup_logs" {
  name              = "/plat/${var.environment}/rabbitmq-backup/${var.broker_name}"
  retention_in_days = 30

  tags = merge(var.tags, {
    Environment = var.environment
    ManagedBy   = "terraform"
    Project     = var.project_tag
  })
}

################################################################################
# IAM Role - Lambda execution
################################################################################

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "backup_lambda" {
  name               = "plat-${var.environment}-rmq-backup-${var.broker_name}"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json

  tags = merge(var.tags, {
    Environment = var.environment
    ManagedBy   = "terraform"
    Project     = var.project_tag
  })
}

data "aws_iam_policy_document" "backup_lambda_policy" {
  statement {
    sid    = "AllowS3Write"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:ListBucket",
    ]
    resources = [
      aws_s3_bucket.rabbitmq_backup.arn,
      "${aws_s3_bucket.rabbitmq_backup.arn}/*",
    ]
  }

  statement {
    sid       = "AllowSecretsRead"
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue"]
    resources = ["arn:aws:secretsmanager:*:*:secret:${var.secret_name}*"]
  }

  dynamic "statement" {
    for_each = var.broker_type == "amazon_mq" ? [1] : []
    content {
      sid    = "AllowAmazonMQDescribe"
      effect = "Allow"
      actions = [
        "mq:DescribeBroker",
        "mq:ListBrokers",
      ]
      resources = ["*"]
    }
  }

  statement {
    sid    = "AllowCloudWatchLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["${aws_cloudwatch_log_group.backup_logs.arn}:*"]
  }
}

resource "aws_iam_policy" "backup_lambda" {
  name   = "plat-${var.environment}-rmq-backup-${var.broker_name}-policy"
  policy = data.aws_iam_policy_document.backup_lambda_policy.json
}

resource "aws_iam_role_policy_attachment" "backup_lambda" {
  role       = aws_iam_role.backup_lambda.name
  policy_arn = aws_iam_policy.backup_lambda.arn
}

################################################################################
# Lambda Function (Python 3.12 - wraps backup shell scripts)
################################################################################

locals {
  script_filename = var.broker_type == "amazon_mq" ? "backup_amazon_mq.sh" : "backup_ecs_rabbitmq.sh"
  script_path     = "${path.module}/scripts/${local.script_filename}"
  lambda_zip_path = "${path.module}/scripts/lambda_${var.broker_type}.zip"
}

data "archive_file" "backup_lambda" {
  type        = "zip"
  output_path = local.lambda_zip_path

  source {
    content  = file("${path.module}/scripts/lambda_handler.py")
    filename = "lambda_handler.py"
  }

  source {
    content  = file(local.script_path)
    filename = local.script_filename
  }
}

resource "aws_lambda_function" "rabbitmq_backup" {
  function_name    = "plat-${var.environment}-rmq-backup-${var.broker_name}"
  role             = aws_iam_role.backup_lambda.arn
  handler          = "lambda_handler.handler"
  runtime          = "python3.12"
  timeout          = 300
  memory_size      = 256
  filename         = data.archive_file.backup_lambda.output_path
  source_code_hash = data.archive_file.backup_lambda.output_base64sha256

  environment {
    variables = {
      BROKER_TYPE         = var.broker_type
      ENVIRONMENT         = var.environment
      AWS_REGION          = var.aws_region
      S3_BUCKET           = var.s3_bucket_name
      S3_PREFIX           = var.s3_prefix
      SECRET_NAME         = var.secret_name
      USERNAME_KEY        = var.username_key
      PASSWORD_KEY        = var.password_key
      CLUSTER_NAME        = var.broker_name
      MGMT_HOST           = var.mgmt_host
      AMAZON_MQ_BROKER_ID = var.amazon_mq_broker_id
      LOG_GROUP           = aws_cloudwatch_log_group.backup_logs.name
    }
  }

  logging_config {
    log_format = "Text"
    log_group  = aws_cloudwatch_log_group.backup_logs.name
  }

  tags = merge(var.tags, {
    Name        = "plat-${var.environment}-rmq-backup-${var.broker_name}"
    Environment = var.environment
    ManagedBy   = "terraform"
    Project     = var.project_tag
  })
}

################################################################################
# EventBridge Rule - Daily Schedule
################################################################################

resource "aws_cloudwatch_event_rule" "backup_schedule" {
  name                = "plat-${var.environment}-rmq-backup-${var.broker_name}-schedule"
  description         = "Daily RabbitMQ definitions backup - ${var.broker_name} (${var.broker_type})"
  schedule_expression = var.backup_schedule

  tags = merge(var.tags, {
    Environment = var.environment
    ManagedBy   = "terraform"
    Project     = var.project_tag
  })
}

resource "aws_cloudwatch_event_target" "backup_lambda" {
  rule      = aws_cloudwatch_event_rule.backup_schedule.name
  target_id = "rmq-backup-${var.broker_name}-lambda"
  arn       = aws_lambda_function.rabbitmq_backup.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.rabbitmq_backup.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.backup_schedule.arn
}
