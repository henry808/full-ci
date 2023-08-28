# Build a webserver s3 bucket
#
# To run:
# cd tf/s3bucket
# terraform plan -var-file="prod.tfvars"
# terraform apply -var-file="prod.tfvars"

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
  # region = "us-west-2" # configured as env vars
  # access_key = "my-access-key" # configured as env vars
  # secret_key = "my-secret-key" # configured as env vars
}



# Specify all environments.
locals{
  environments = ["dev", "test", "prod" ]
}






# S3 Bucket - only the owner can access
# Can add a policy or IAM access later to allow others to access this bucket.
resource "aws_s3_bucket" "s3bucket" {
  count = length(local.environments)

  bucket = "${var.company_name}-${var.project_name}-s3bucket-${local.environments[count.index]}"  # Ensure this name is globally unique

  tags = {
    Name        = "${var.company_name}-${var.project_name}-s3bucket-${local.environments[count.index]}"
    Environment = local.environments[count.index]
  }
}