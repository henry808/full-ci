terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

variable "env" {
  default = "${env}"
}

# Configure the AWS Provider
provider "aws" {
  # access_key = "my-access-key"
  # secret_key = "my-secret-key"
}

# AWS EC2
resource "aws_instance" "webserver-ec2-${env}" {
  ami = "ami-03f65b8614a860c29" # ubuntu 22.04 x86
  instance_type = "t2.micro"

  # Reference the security group
  vpc_security_group_ids = [aws_security_group.webserver-ec2-sg-${env}.id]

  tags = {
    Name = "webserver-ec2-${env}"
  }

  key_name = aws_key_pair.webserver-ec2-key-pair-${env}.key_name
}

resource "aws_key_pair" "webserver-ec2-key-pair-${env}" { 
  key_name = "webserver-ec2-key-pair-${env}"
  public_key = file("~/.ssh/gitlab072723.pub")
}

# SG for EC2 instance
resource "aws_security_group" "webserver-ec2-sg-${env}" {
  name        = "webserver-ec2-sg-${env}"
  
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

  ingress {
  from_port                = 8080 
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.webserver_alb_sg-${env}.id
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
    Name = "webserver-ec2-sg-${env}"
  }
}

# Define ALB Listener and Target group and SG

# SG for ALB
resource "aws_security_group" "webserver_alb_sg-${env}" {
  name        = "webserver_alb_sg-${env}"
  
  # Allow inbound HTTP traffic on port 80 from anywhere
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    source_security_group_id = aws_security_group.webserver-ec2-${env}.id
  }

  # Allow all outbound traffic
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = {
    Name = "webserver_alb_sg-${env}"
  }
}

# ALB
resource "aws_lb" "webserver-alb-${env}" {
  name               = "webserver-alb-${env}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.webserver_alb_sg-${env}.id]
  subnets            = ["subnet-ec528b94", "subnet-6619b13b", "subnet-3df00a77"] # using default subnets a,b,c

  tags = {
    Name = "webserver-alb-${env}"
  }
}

# Target Group
resource "aws_lb_target_group" "webserver-tg-${env}" {
  name     = "webserver-tg-${env}"
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
    Name = "webserver-tg-${env}"
  }
}

# ALB Listener
resource "aws_lb_listener" "webserver-front-end-${env}" {
  load_balancer_arn = aws_lb.webserver-alb-${env}.arn
  port              = 8080
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.webserver-tg-${env}.arn
  }

}
