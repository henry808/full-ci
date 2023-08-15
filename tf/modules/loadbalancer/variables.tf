# Parameters for module.
variable "env" {
  type = string
  description = "Environment (dev, test, prod)"
}

variable "project_name" {
  type = string
  description = "Unique project name"
}

variable "ec2_sg_id" {
  type = string
  description = "ID of Instance Security Group needed for connection with ALB SG"
}

variable "subnets" {
  type = list(string)
  description = "List of subnets"
}

variable "ec2_instance_id" {
  type = string
  description = "Instance ID"  
}