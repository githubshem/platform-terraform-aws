output "backup_bucket_name" {
  description = "Name of the S3 bucket storing Terraform state backups"
  value       = aws_s3_bucket.state_backup.bucket
}

output "backup_bucket_arn" {
  description = "ARN of the Terraform state backup bucket"
  value       = aws_s3_bucket.state_backup.arn
}
