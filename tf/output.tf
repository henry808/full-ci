# Output for project
output ec2 {
  value = module.instances.ec2_list.*.public_dns
  description = "EC2 Security Group full obj"
}

output lb {
  value = module.loadbalancer.alb.dns_name
  description = "ALB full obj"
}