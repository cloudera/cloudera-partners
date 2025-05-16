# Key Pair Outputs
output "keypair_name" {
  value       = module.key-pair.keypair_name
  description = "The name of the SSH key pair used to access the EC2 instances"
}

# Security Group Outputs
output "sec_group_details" {
  value       = module.security_group.security_group_id
  description = "The security group ID created by the module or the name of the existing security group used"
}

# VPC Outputs
output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "The ID of the VPC being used, either newly created or existing"
}

output "subnet_ids" {
  value       = module.vpc.subnet_ids
  description = "A list of subnet IDs within the selected or created VPC"
}

output "vpc_name" {
  value       = module.vpc.vpc_name
  description = "The name tag associated with the VPC when a new one is created"
}

output "default_vpc_name" {
  value       = module.vpc.default_vpc_name
  description = "The name tag of the default VPC, used when create_vpc is set to false"
}

# EC2 Instance Outputs
output "cldr_mngr_public_ip" {
  value       = module.elastic-ip.eip_public_ip
  description = "The public IP address assigned to the Cloudera Manager instance via an Elastic IP"
}

output "instance_groups" {
  value       = var.instance_groups
  description = "A map of EC2 instance group names to their respective configuration values (count, instance type, etc.)"
}

output "instance_ids" {
  value       = module.ec2_instances.instance_ids
  description = "A map of instance group names to the list of EC2 instance IDs created in each group"
}

output "private_ips" {
  value       = module.ec2_instances.private_ips
  description = "A map of instance group names to the list of private IP addresses assigned to EC2 instances"
}

# output "public_ips" {
#   value       = module.ec2_instances.public_ips
#   description = "A map of instance group names to the list of public IP addresses assigned to EC2 instances"
# }

output "public_ips" {
  value = local.final_public_ips
}

# Elastic IP Outputs
output "cldr_mngr_eip_association_id" {
  value       = module.ec2_instances.eip_association_id
  description = "The association ID for the Cloudera Manager EIP"
}

output "eip_allocation_id" {
  value       = module.elastic-ip.eip_allocation_id
  description = "The EIP allocation ID of cldr-mngr-1"
}

