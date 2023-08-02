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

# AWS EC2
resource "aws_instance" "web1" {
  ami = "ami-03f65b8614a860c29" # ubuntu 22.04 x86
  instance_type = "t2.micro"

  # Reference the security group
  vpc_security_group_ids = [aws_security_group.web1_sg.id]

  tags = {
    Name = "web-service"
  }

  key_name = aws_key_pair.web1_ec2_key_pair.key_name
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
    Name = "web1_sg"
  }
}

# Define ALB Listener and Target group

# ALB
resource "aws_lb" "alb" {
  name               = "web1-service-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web1_sg.id]
  subnets            = ["subnet-ec528b94", "subnet-6619b13b", "subnet-3df00a77"] # using default subnets a,b,c

  tags = {
    Name = "web1-service-alb"
  }
}

# Target Group
resource "aws_lb_target_group" "web1_tg" {
  name     = "web1-service-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = "vpc-38dd9140"

  health_check {
    enabled             = true
    interval            = 30
    path                = "/"
    timeout             = 3
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  tags = {
    Name = "web1-service-tg"
  }
}

# ALB Listener
resource "aws_lb_listener" "web1_front_end" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web1_tg.arn
  }
}