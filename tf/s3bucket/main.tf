# Build a webserver s3 bucket
#
# To run:
# cd tf/s3bucket
# terraform plan -var-file="prod.tfvars"
# terraform apply -var-file="prod.tfvars"

terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
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


# Specify all needed environments here
locals{
  environments = ["dev", "test", "prod" ]
}


# Group to access bucket
# Add user or service account to this group to give access to bucket
resource "aws_iam_group" "access_group" {
  name = "${var.company_name}-${var.project_name}"
}

# S3 Bucket
resource "aws_s3_bucket" "s3bucket" {
  count = length(local.environments)

  bucket = "${var.company_name}-${var.project_name}-s3bucket-${local.environments[count.index]}"  # Ensure this name is globally unique

  tags = {
    Name        = "${var.company_name}-${var.project_name}-s3bucket-${local.environments[count.index]}"
    Environment = local.environments[count.index]
  }
}

# Policy that allows what is needed for terraform state file
resource "aws_s3_bucket_policy" "s3_bucket_policy" {
  count  = length(local.environments)
  bucket = aws_s3_bucket.s3bucket[count.index].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:group/${aws_iam_group.access_group.name}"
        }
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.s3bucket[count.index].id}",
          "arn:aws:s3:::${aws_s3_bucket.s3bucket[count.index].id}/*"
        ]
      }
    ]
  })
}

data "aws_caller_identity" "current" {}

output "iam_group_arn" {
  value = aws_iam_group.example_group.arn
}