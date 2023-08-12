terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Variables defined in variables.tf and set in main.tf



# Configure the AWS Provider
provider "aws" {
  # access_key = "my-access-key" # configured as env vars
  # secret_key = "my-secret-key" # configured as env vars
}

# AWS EC2
resource "aws_instance" "ec2" {
  ami = var.ami
  instance_type = var.instance_type

  # Reference the security group
  vpc_security_group_ids = [aws_security_group.ec2-sg.id]

  tags = {
    Name = "${var.project_name}-ec2-${var.env}"
  }

  key_name = aws_key_pair.ec2-key-pair.key_name
}

# Define ALB Listener and Target group and SG

# SG for ALB
resource "aws_security_group" "alb-sg" {
  name        = "${var.project_name}_alb_sg-${var.env}"
  
  # Allow inbound HTTP traffic on port 8080 from anywhere (listener)
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2-sg.id]
  }

  tags = {
    Name = "${var.project_name}_alb_sg-${var.env}"
  }
}

# ALB
resource "aws_lb" "alb" {
  name               = "${var.project_name}-alb-${var.env}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb-sg.id]
  subnets            = ["subnet-ec528b94", "subnet-6619b13b", "subnet-3df00a77"] # using default subnets a,b,c

  tags = {
    Name = "${var.project_name}-alb-${var.env}"
  }
}

# Target Group
resource "aws_lb_target_group" "tg" {
  name     = "${var.project_name}-tg-${var.env}"
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
    protocol = "HTTP"
    port = "8080"
  }

  tags = {
    Name = "${var.project_name}-tg-${var.env}"
  }
}

resource "aws_lb_target_group_attachment" "tg-attachment" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.ec2.id
  port             = 8080
}

# ALB Listener
resource "aws_lb_listener" "front-end" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 8080
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}
