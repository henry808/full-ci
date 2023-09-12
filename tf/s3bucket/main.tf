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
locals {
  environments = ["dev", "test", "prod"]
}

# S3 Bucket
resource "aws_s3_bucket" "s3bucket" {
  count = length(local.environments)

  bucket = "${var.company_name}-${var.project_name}-s3bucket-${local.environments[count.index]}" # Ensure this name is globally unique

  tags = {
    Name        = "${var.company_name}-${var.project_name}-s3bucket-${local.environments[count.index]}"
    Environment = local.environments[count.index]
  }
}

# Group to access bucket
# Add user or service account to this group to give access to bucket
resource "aws_iam_group" "access_group" {
  name = "${var.company_name}-${var.project_name}"
}

# IAM policy to grant specific access to the S3 buckets for the IAM group.
# This policy helps in maintaining secure access to the buckets, letting only group members perform these actions.
resource "aws_iam_group_policy" "group_policy" {
  name  = "${var.company_name}-${var.project_name}-policy"
  group = aws_iam_group.access_group.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      # Allows the group to list the buckets, get the bucket locations, and list multipart uploads in the buckets.
      {
        Effect   = "Allow",
        Action   = [
          "s3:ListBucket",
          "s3:GetBucketLocation",
          "s3:ListBucketMultipartUploads",
        ],
        Resource = [
          for bucket in aws_s3_bucket.s3bucket : bucket.arn
        ]
      },
      # Allows the group to perform object-level actions (put, get, delete) and manage multipart uploads within the buckets.
      {
        Effect   = "Allow",
        Action   = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:ListMultipartUploadParts",
          "s3:AbortMultipartUpload",
        ],
        Resource = [
          for bucket in aws_s3_bucket.s3bucket : "${bucket.arn}/*"
        ]
      },
    ]
  })
}

data "aws_caller_identity" "current" {}

output "iam_group_arn" {
  value = aws_iam_group.access_group.arn
}