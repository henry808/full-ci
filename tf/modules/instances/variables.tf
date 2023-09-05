# Parameters for module.
variable "env" {
  type        = string
  description = "Environment (dev, test, prod)"
}

variable "project_name" {
  type        = string
  description = "Unique project name"
}

variable "instance_count" {
  type        = number
  description = "Number of ec2 instances"
}

variable "instance_type" {
  type        = string
  description = "Instance Type"
}

variable "subnets" {
  type        = list(string)
  description = "List of subnets"
}

variable "ami" {
  type        = string
  description = "AMI"
}

variable "local_keypair_path" {
  type        = string
  description = "Keypair path to pub keypair file on local computer (~/.ssh/example.pub)"
}