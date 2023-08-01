terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  # access_key = "my-access-key"
  # secret_key = "my-secret-key"
}

# ami = ubuntu 22.04 x86
resource "aws_instance" "web1" {
  ami = "ami-03f65b8614a860c29"
  instance_type = "t2.micro"

  # Reference the security group
  vpc_security_group_ids = [aws_security_group.web1_sg.id]

  tags = {
    Name = "web-service"
  }
}

resource "aws_key_pair" "web1_ec2_key_pair" { 
  key_name = "web1-ec2-key-pair"
  public_key = file("~/.ssh/gitlab072723.pub")
}

# Create a security group to allow SSH access
resource "aws_security_group" "web1_sg" {
  name        = "web_sg"
  
  # SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  # http access
  ingress {
    from_port   = 80 
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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
    Name = "web1_sg"
  }
}
