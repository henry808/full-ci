# Parameters for module.
variable "env" {
  type = string
  description = "Environment (dev, test, prod)"
}

variable "project_name" {
  type = string
  description = "Unique project name"
}

variable "instance_type" {
  type = string
  description = "Instance Type"
}

variable "subnets" {
  type = list(string)
  description = "List of subnets"
}

variable "ec2_instance_id" {
  type = string
  description = "Instance ID"  
}