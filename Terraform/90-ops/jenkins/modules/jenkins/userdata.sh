#!/bin/bash
# Redirect output to log for debugging
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

echo "Starting Jenkins Setup..."

# 1. Update and install dependencies
apt-get update -y
apt-get install -y nfs-common openjdk-17-jdk curl ca-certificates gnupg

# 2. EFS Mounting (Critical)
mkdir -p /var/lib/jenkins
# We use the variable placeholders that Terraform fills in
mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${efs_id}.efs.${region}.amazonaws.com:/ /var/lib/jenkins

# 3. Add Jenkins Repository (Modern Method for Ubuntu 24.04)
# Download the key and dearmor it for apt
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | gpg --dearmor -o /usr/share/keyrings/jenkins-keyring.gpg

# Add the repo referencing the keyring
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.gpg] https://pkg.jenkins.io/debian-stable binary/" | tee /etc/apt/sources.list.d/jenkins.list > /dev/null

# 4. Install Jenkins
apt-get update -y
apt-get install -y jenkins

# 5. Permissions and Start
chown -R jenkins:jenkins /var/lib/jenkins
systemctl daemon-reload
systemctl enable jenkins
systemctl start jenkins

echo "Installation Complete."