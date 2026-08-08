# Dynamic AMI Lookup for the latest Ubuntu 24.04
data "aws_ami" "ubuntu_24" {
  most_recent = true
  owners      = ["099720109477"] # Canonical's AWS ID

  filter {
    name = "name"
    # Using a wildcard '*' to find the latest 24.04 amd64 server image
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
