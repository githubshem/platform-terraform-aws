resource "aws_instance" "jenkins_server" {
  ami                         = data.aws_ami.ubuntu_24.id
  instance_type               = var.instance_type
  subnet_id                   = var.public_subnet_ids[0]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.jenkins_profile.name
  vpc_security_group_ids      = [aws_security_group.jenkins_sg.id]

  # This is the "bridge" between Terraform and the Shell Script
  user_data = templatefile("${path.module}/userdata.sh", {
    efs_id = aws_efs_file_system.jenkins_home.id
    region = var.aws_region
  })

  tags = { Name = "${var.project_name}-${var.environment}-jenkins" }
}