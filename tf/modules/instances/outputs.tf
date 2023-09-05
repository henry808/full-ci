# Output for EC2 Instance
output "ec2-sg" {
  value       = aws_security_group.ec2-sg
  description = "EC2 Security Group full obj"
}

output "ec2_list" {
  value       = aws_instance.ec2
  description = "EC2 Instance full obj"
}