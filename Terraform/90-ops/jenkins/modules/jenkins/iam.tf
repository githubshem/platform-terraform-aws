# Instance role for the Jenkins controller.
#
# Scope: this role covers what the *host* does, not what the Terraform pipelines
# do. Those pipelines authenticate with the AWS_SESSION_TOKEN Jenkins credential
# (see AWS_CRED_ID in every Jenkinsfile), so their apply permissions live with
# that credential and deliberately do NOT belong here. Granting Terraform-apply
# rights to the instance role would silently give every job on the box — and
# anyone who can define one — full infrastructure access without going through
# the credential.
#
# What genuinely runs as the instance role is the two scheduled backup jobs,
# which call the AWS CLI directly with no withCredentials wrapper:
#   - Jenkinsfile.terraform-state-backup: reads both live state buckets, writes
#     the state-backup bucket.
#   - Jenkinsfile.rabbitmq-backup: writes RabbitMQ definition exports.
# Plus Session Manager, so the box is administrable without opening SSH, and
# EFS client mount for the Jenkins home directory.
resource "aws_iam_role" "jenkins" {
  name = "${var.project_name}-${var.environment}-jenkins-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = "sts:AssumeRole"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })

  tags = { Name = "${var.project_name}-${var.environment}-jenkins-role" }
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.jenkins.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy" "efs_mount" {
  name = "${var.project_name}-${var.environment}-jenkins-efs-mount"
  role = aws_iam_role.jenkins.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "elasticfilesystem:ClientMount",
        "elasticfilesystem:ClientWrite",
        "elasticfilesystem:DescribeMountTargets",
      ]
      Resource = aws_efs_file_system.jenkins_home.arn
    }]
  })
}

# Backup jobs. Read is scoped to the live state buckets and write to the backup
# buckets -- never the reverse, so a bug in these jobs cannot damage live state.
# No s3:DeleteObject anywhere: neither job runs `sync --delete`, and withholding
# delete means a compromised job cannot erase the backups either.
resource "aws_iam_role_policy" "backup_jobs" {
  name = "${var.project_name}-${var.environment}-jenkins-backup-jobs"
  role = aws_iam_role.jenkins.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "ReadLiveStateBuckets"
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:GetObjectVersion"]
        Resource = [for b in var.state_buckets : "arn:aws:s3:::${b}/*"]
      },
      {
        Sid      = "ListLiveStateBuckets"
        Effect   = "Allow"
        Action   = ["s3:ListBucket", "s3:ListBucketVersions"]
        Resource = [for b in var.state_buckets : "arn:aws:s3:::${b}"]
      },
      {
        Sid    = "WriteBackupBuckets"
        Effect = "Allow"
        Action = ["s3:PutObject"]
        Resource = [
          "arn:aws:s3:::${var.state_backup_bucket}/*",
          "arn:aws:s3:::${var.rabbitmq_backup_bucket}/*",
        ]
      },
      {
        Sid    = "InspectBackupBuckets"
        Effect = "Allow"
        Action = ["s3:ListBucket"]
        Resource = [
          "arn:aws:s3:::${var.state_backup_bucket}",
          "arn:aws:s3:::${var.rabbitmq_backup_bucket}",
        ]
      },
    ]
  })
}

resource "aws_iam_instance_profile" "jenkins_profile" {
  name = "${var.project_name}-${var.environment}-jenkins-profile"
  role = aws_iam_role.jenkins.name
}
