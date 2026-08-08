# Jenkins keeps its home directory (jobs, plugins, build history) on EFS so the
# controller instance stays replaceable. userdata.sh mounts this by DNS name at
# /var/lib/jenkins.
#
# This file and iam.tf were empty in the sanitized baseline, so the stack could
# not validate: main.tf referenced both aws_efs_file_system.jenkins_home and
# aws_iam_instance_profile.jenkins_profile without either being declared.
resource "aws_efs_file_system" "jenkins_home" {
  creation_token = "${var.project_name}-${var.environment}-jenkins-home"
  encrypted      = true

  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }

  tags = { Name = "${var.project_name}-${var.environment}-jenkins-home" }
}

# EFS resolves its DNS name to the mount target in the caller's AZ, so the
# controller can only mount if its own AZ has one. Covering every public subnet
# keeps the instance movable across AZs without a follow-up apply.
resource "aws_efs_mount_target" "jenkins_home" {
  for_each = toset(var.public_subnet_ids)

  file_system_id  = aws_efs_file_system.jenkins_home.id
  subnet_id       = each.value
  security_groups = [aws_security_group.efs_sg.id]
}
