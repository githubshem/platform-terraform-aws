# ======================================================================
# 1. VARIABLES TO UPDATE (Fill these in before running!)
# ======================================================================
variable "vpc_id" { default = "vpc-0aaa111bbb222ccc" }
variable "locked_subnet_id" { default = "subnet-0ccc333ddd444eee" } # Must lock to 1 subnet for EBS attachment
variable "target_cluster_name" { default = "plat-prod-keycloak-rabbitmq" }

# YOUR CUSTOM DOCKER IMAGE (From Phase 1)
variable "rabbitmq_image" { default = "YOUR_ACCOUNT_ID.dkr.ecr.ap-southeast-1.amazonaws.com/custom-rabbitmq:latest" }

# YOUR EXISTING NLB DETAILS
variable "existing_nlb_arn" { default = "arn:aws:elasticloadbalancing:ap-southeast-1:123456789012:loadbalancer/net/plat-prod-logstash-lb/a55fcaddf6a9d6cc" }
# If your NLB has a Security Group attached, put its ID here to auto-allow Port 5672. 
# If your NLB does NOT use an SG, leave this as an empty string "".
variable "existing_nlb_sg_id" { default = "sg-0bbb222ccc333ddd" }

# ======================================================================
# 2. DATA BLOCKS (Fetches VPC info dynamically)
# ======================================================================
data "aws_subnet" "locked_az" {
  id = var.locked_subnet_id
}

data "aws_vpc" "main" {
  id = var.vpc_id
}

# ======================================================================
# 3. EXISTING NLB SECURITY GROUP UPDATE
# ======================================================================
# Automatically injects an Ingress rule into your existing NLB SG if provided
resource "aws_security_group_rule" "existing_nlb_amqp_ingress" {
  count             = var.existing_nlb_sg_id != "" ? 1 : 0
  type              = "ingress"
  from_port         = 5672
  to_port           = 5672
  protocol          = "tcp"
  cidr_blocks       = [data.aws_vpc.main.cidr_block] # Allows internal VPC traffic
  security_group_id = var.existing_nlb_sg_id
}

# ======================================================================
# 4. RABBITMQ EC2 SECURITY GROUP
# ======================================================================
resource "aws_security_group" "rabbitmq_ec2_sg" {
  name        = "rabbitmq-dedicated-ec2-sg"
  description = "Allows AMQP and Management traffic for RabbitMQ"
  vpc_id      = var.vpc_id

  ingress {
    description = "AMQP TCP Traffic"
    from_port   = 5672
    to_port     = 5672
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.main.cidr_block]
  }

  ingress {
    description = "Management UI HTTP"
    from_port   = 15672
    to_port     = 15672
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.main.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ======================================================================
# 5. PERSISTENT EBS VOLUME
# ======================================================================
resource "aws_ebs_volume" "rabbitmq_data" {
  availability_zone = data.aws_subnet.locked_az.availability_zone
  size              = 50
  type              = "gp3"
  tags = {
    Name = "rabbitmq-persistent-storage"
  }
}

# ======================================================================
# 6. IAM ROLE POLICY (Allows EC2 to attach the EBS Volume)
# ======================================================================
resource "aws_iam_role_policy" "ec2_attach_volume" {
  name = "ec2-attach-rabbitmq-volume"
  role = "ecsInstanceRole" # Your existing EC2 profile role name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["ec2:AttachVolume", "ec2:DescribeVolumes"]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

# ======================================================================
# 7. EC2 LAUNCH TEMPLATE & ASG
# ======================================================================
resource "aws_launch_template" "rabbitmq_node" {
  name_prefix   = "rabbitmq-dedicated-node-"
  image_id      = "ami-0ddd444eee555fff"
  instance_type = "r7i.large"

  iam_instance_profile {
    name = "ecsInstanceRole"
  }

  vpc_security_group_ids = [aws_security_group.rabbitmq_ec2_sg.id]

  # DYNAMIC USER DATA: Tags instance, attaches the exact volume, formats, and mounts
  user_data = base64encode(<<-EOF
    #!/bin/bash
    echo 'ECS_CLUSTER=${var.target_cluster_name}' >> /etc/ecs/ecs.config
    echo 'ECS_INSTANCE_ATTRIBUTES={"dedicated":"rabbitmq"}' >> /etc/ecs/ecs.config
    
    INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
    aws ec2 attach-volume --volume-id ${aws_ebs_volume.rabbitmq_data.id} --instance-id $INSTANCE_ID --device /dev/sdf --region ap-southeast-1
    
    # Wait for Nitro instance to map /dev/sdf to NVMe
    sleep 15
    DEVICE="/dev/nvme1n1"
    
    # Format if empty (new volume), otherwise skip to prevent data loss
    if ! blkid $DEVICE; then
      mkfs -t xfs $DEVICE
    fi
    
    mkdir -p /mnt/rabbitmq-data
    mount $DEVICE /mnt/rabbitmq-data
    chown -R 999:999 /mnt/rabbitmq-data
  EOF
  )
}

resource "aws_autoscaling_group" "rabbitmq_asg" {
  name                = "rabbitmq-dedicated-asg"
  vpc_zone_identifier = [var.locked_subnet_id]
  min_size            = 1
  max_size            = 1
  desired_capacity    = 1

  launch_template {
    id      = aws_launch_template.rabbitmq_node.id
    version = "$Latest"
  }
}

# ======================================================================
# 8. ATTACH TO EXISTING NLB
# ======================================================================
resource "aws_lb_target_group" "rabbitmq_amqp" {
  name        = "rabbitmq-amqp-tg-up"
  port        = 5672
  protocol    = "TCP"
  vpc_id      = var.vpc_id
  target_type = "ip" # Required for awsvpc network mode
}

resource "aws_lb_listener" "rabbitmq_amqp_listener" {
  load_balancer_arn = var.existing_nlb_arn
  port              = 5672
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.rabbitmq_amqp.arn
  }
}

# ======================================================================
# 9. ECS LOGS, TASK DEFINITION & SERVICE
# ======================================================================
resource "aws_cloudwatch_log_group" "rabbitmq_logs" {
  name              = "/ecs/rabbitmq-dedicated"
  retention_in_days = 30
}

resource "aws_ecs_task_definition" "rabbitmq" {
  family                   = "rabbitmq-dedicated-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  cpu                      = 1024
  memory                   = 4096
  execution_role_arn       = "arn:aws:iam::123456789012:role/ecsTaskExecutionRole"

  # The Bind Mount mapping the EC2 Host to the Container
  volume {
    name      = "rabbitmq-storage"
    host_path = "/mnt/rabbitmq-data"
  }

  container_definitions = jsonencode([
    {
      name      = "rabbitmq"
      image     = var.rabbitmq_image
      essential = true

      portMappings = [
        { containerPort = 5672, hostPort = 5672, protocol = "tcp" },
        { containerPort = 15672, hostPort = 15672, protocol = "tcp" }
      ]

      mountPoints = [
        {
          sourceVolume  = "rabbitmq-storage"
          containerPath = "/var/lib/rabbitmq/mnesia" # The critical data folder
          readOnly      = false
        }
      ]

      environment = [
        { name = "RABBITMQ_DEFAULT_USER", value = "admin" },
        { name = "RABBITMQ_DEFAULT_PASS", value = "SuperSecretPassword123!" }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.rabbitmq_logs.name
          "awslogs-region"        = "ap-southeast-1"
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "rabbitmq" {
  name            = "rabbitmq-broker"
  cluster         = var.target_cluster_name
  task_definition = aws_ecs_task_definition.rabbitmq.arn
  desired_count   = 1
  launch_type     = "EC2"

  # Wait for the listener to attach to the existing NLB before deploying the task
  depends_on = [aws_lb_listener.rabbitmq_amqp_listener]

  # Force the task to ONLY run on our dedicated RabbitMQ EC2 instance
  placement_constraints {
    type       = "memberOf"
    expression = "attribute:dedicated == rabbitmq"
  }

  network_configuration {
    subnets         = [var.locked_subnet_id]
    security_groups = [aws_security_group.rabbitmq_ec2_sg.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.rabbitmq_amqp.arn
    container_name   = "rabbitmq"
    container_port   = 5672
  }
}