terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

variable "env" {
  default = "prod"
}

# Configure the AWS Provider
provider "aws" {
  # access_key = "my-access-key"
  # secret_key = "my-secret-key"
}

# AWS EC2
resource "aws_instance" "webserver-ec2-prod" {
  ami = "ami-03f65b8614a860c29" # ubuntu 22.04 x86
  instance_type = "t2.micro"

  # Reference the security group
  vpc_security_group_ids = [aws_security_group.webserver-ec2-sg-prod.id]

  tags = {
    Name = "webserver-ec2-${var.env}"
  }

  key_name = aws_key_pair.webserver-ec2-key-pair-prod.key_name
}

resource "aws_key_pair" "webserver-ec2-key-pair-prod" { 
  key_name = "webserver-ec2-key-pair-${var.env}"
  public_key = file("~/.ssh/gitlab072723.pub")
}

# SG for EC2 instance
resource "aws_security_group" "webserver-ec2-sg-prod" {
  name        = "webserver-ec2-sg-${var.env}"
  
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

  # # ALB http access
  # ingress {
  #   from_port                = 8080 
  #   to_port                  = 8080
  #   protocol                 = "tcp"
  #   security_groups = [aws_security_group.webserver_alb_sg-prod.id]
  # }
  
  # download or install from anywhere
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  # name
  tags = {
    Name = "webserver-ec2-sg-${var.env}"
  }
}

# Define ALB Listener and Target group and SG

# SG for ALB
resource "aws_security_group" "webserver_alb_sg-prod" {
  name        = "webserver_alb_sg-${var.env}"
  
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
    security_groups = [aws_security_group.webserver-ec2-sg-prod.id]
  }

  tags = {
    Name = "webserver_alb_sg-${var.env}"
  }
}

# ALB
resource "aws_lb" "webserver-alb-prod" {
  name               = "webserver-alb-${var.env}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.webserver_alb_sg-prod.id]
  subnets            = ["subnet-ec528b94", "subnet-6619b13b", "subnet-3df00a77"] # using default subnets a,b,c

  tags = {
    Name = "webserver-alb-${var.env}"
  }
}

# Target Group
resource "aws_lb_target_group" "webserver-tg-prod" {
  name     = "webserver-tg-${var.env}"
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
    Name = "webserver-tg-${var.env}"
  }
}

resource "aws_lb_target_group_attachment" "webserver-tg-attachment-prod" {
  target_group_arn = aws_lb_target_group.webserver-tg-prod.arn
  target_id        = aws_instance.webserver-ec2-prod.id
  port             = 8080
}

# ALB Listener
resource "aws_lb_listener" "webserver-front-end-prod" {
  load_balancer_arn = aws_lb.webserver-alb-prod.arn
  port              = 8080
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.webserver-tg-prod.arn
  }

}
