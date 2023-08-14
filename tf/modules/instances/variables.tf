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

variable "ami" {
  type = string
  description = "AMI"
}

variable "local_keypair_path" {
  type = string
  description = "Keypair path to pub keypair file on local computer (~/.ssh/example.pub)"  
}