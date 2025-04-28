output "public_ip" {
  value = module.ec2.public_ip
}

# Output the instance name
output "instance_name" {
  value = module.ec2.instance_name
}