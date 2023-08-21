# Instances and keypair and SG for instances
terraform {
}


resource "aws_key_pair" "ec2-key-pair" { 
  key_name = "${var.project_name}-ec2-key-pair-${var.env}"
  public_key = file(var.local_keypair_path)
}

# AWS EC2
resource "aws_instance" "ec2" {
  count = var.instance_count
  ami = var.ami
  instance_type = var.instance_type
  subnet_id = var.subnets[count.index % length(var.subnets)]

  # Reference the security group
  vpc_security_group_ids = [aws_security_group.ec2-sg.id]

  tags = {
    Name = "${var.project_name}-ec2-${var.env}-${count.index + 1}"
  }

  key_name = aws_key_pair.ec2-key-pair.key_name
}

# SG for EC2 instance
resource "aws_security_group" "ec2-sg" {
  name        = "${var.project_name}-ec2-sg-${var.env}"
  
  # SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  # http access
  ingress {
    from_port   = 8080 
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP traffic on port 8080"
  }

  # download or install from anywhere
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  # name
  tags = {
    Name = "${var.project_name}-ec2-sg-${var.env}"
  }
}