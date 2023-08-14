# Output for EC2 Instance
output alb {
  value = aws_instance.ec2
  description = "ALB full obj"
}