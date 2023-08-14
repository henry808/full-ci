# Output for EC2 Instance
output ec2-sg {
  value = aws_security_group.ec2-sg
  description = "EC2 Security Group full obj"
}

output ec2 {
  value = aws_instance.ec2
  description = "Instance full obj"
}