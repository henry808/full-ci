# Variables set in .tfvars file
variable "company_name" {
  type        = string
  description = "Company name for use with s3 bucket and other resources that need to be globally unique."
}

variable "project_name" {
  type        = string
  description = "Unique project name"
}

variable "env" {
  type        = string
  description = "Environment (dev, test, prod)"
}

variable "instance_count" {
  type        = number
  description = "Number of ec2 instances"
}

variable "instance_type" {
  type        = string
  description = "Instance Type"
}

variable "ami" {
  type        = string
  description = "AMI"
}

variable "local_keypair_path" {
  type        = string
  description = "Keypair path to pub keypair file on local computer (~/.ssh/example.pub)"
}

variable "subnets" {
  type        = list(string)
  description = "List of subnets"
}