
# output "private_subnet_ids" {
#   value = module.vpc.private_subnets_cidr
# }

output "vpc_id" {
  value = var.create_vpc ? module.vpc[0].vpc_id : data.aws_vpc.default[0].id
}

output "subnet_ids" {
  value = var.create_vpc ? concat(module.vpc[0].public_subnets, module.vpc[0].private_subnets) : data.aws_subnets.default[0].ids
}

output "vpc_name" {
  description = "The vpc name used for the EC2 instance"
  value       = var.create_vpc == true ? module.vpc[0].name : null
}

output "default_vpc_name" {
  description = "Default VPC name used when create_vpc is false"
  value       = var.create_vpc == false ? lookup(data.aws_vpc.default[0].tags, "Name", null) : null
}
