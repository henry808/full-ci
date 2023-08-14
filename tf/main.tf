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

# EC2 Instances
module "instances" {
  source = "./modules/instances"
  env = var.env
  project_name = var.project_name
  instance_type = var.instance_type
  ami = var.ami
  local_keypair_path = var.local_keypair_path
}

# Load Balancer
module "loadbalancer" {
  source = "./modules/loadbalancer"
  env = var.env
  project_name = var.project_name
  ec2_sg_id = module.instances.ec2-sg.id
  subnets = ["subnet-ec528b94", "subnet-6619b13b", "subnet-3df00a77"] # using default subnets a,b,c
  ec2_instance_id = module.instances.ec2.id
}
