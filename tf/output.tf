# Output for project
output ec2 {
  value = module.ec2.public_dns
  description = "EC2 Security Group full obj"
}

output lb {
  value = module.alb.public_dns
  description = "ALB full obj"
}