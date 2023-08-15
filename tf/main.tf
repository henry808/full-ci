# Build a webserver with load balancer in front of it.
#
# To run:
# cd tf
# terraform plan -var-file="prod.tfvars"

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
  instance_count = var.instance_count
  instance_type = var.instance_type
  ami = var.ami
  local_keypair_path = var.local_keypair_path
  subnets = var.subnets
}

# Load Balancer
module "loadbalancer" {
  source = "./modules/loadbalancer"
  env = var.env
  project_name = var.project_name
  ec2_sg_id = module.instances.ec2-sg.id
  subnets = var.subnets
  ec2_instance_id_list = module.instances.ec2_list[*].id
}
