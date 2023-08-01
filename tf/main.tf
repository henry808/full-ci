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
}