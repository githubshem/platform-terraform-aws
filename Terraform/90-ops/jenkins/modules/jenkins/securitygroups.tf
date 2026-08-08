# Security Group for the Jenkins EC2 Instance
#
# No SSH rule. Administration goes through SSM Session Manager, which the
# instance role grants (see iam.tf) and which needs no inbound rule at all --
# the agent opens an outbound connection instead. Port 22 was previously open
# to 0.0.0.0/0, meaning the whole internet could reach sshd on the controller
# that holds credentials for every environment.
resource "aws_security_group" "jenkins_sg" {
  name        = "${var.project_name}-${var.environment}-jenkins-sg"
  description = "Jenkins controller: UI from approved CIDRs, egress for plugins and AWS APIs"
  vpc_id      = var.vpc_id

  # The UI was also open to 0.0.0.0/0. It is now an explicit allow-list, and
  # var.jenkins_ui_allowed_cidrs has no default, so a caller cannot get the
  # world-open behaviour back by leaving it unset.
  ingress {
    description = "Jenkins UI"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = var.jenkins_ui_allowed_cidrs
  }

  egress {
    description = "Outbound for plugin downloads, AWS APIs and SSM"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project_name}-${var.environment}-jenkins-sg" }
}

# Security Group for EFS (Allows NFS from the Jenkins Instance only)
resource "aws_security_group" "efs_sg" {
  name        = "${var.project_name}-${var.environment}-efs-sg"
  description = "Allow NFS traffic from Jenkins SG"
  vpc_id      = var.vpc_id

  ingress {
    description     = "NFS from the Jenkins controller only"
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.jenkins_sg.id]
  }

  tags = { Name = "${var.project_name}-${var.environment}-efs-sg" }
}
