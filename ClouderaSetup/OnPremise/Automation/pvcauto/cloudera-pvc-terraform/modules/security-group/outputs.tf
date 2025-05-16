# Outputs for the security group module
output "security_group_id" {
  description = "ID of the security group (new or existing)"
  value       = var.create_new_sg == true ? aws_security_group.vpc_sg[0].id : data.aws_security_group.existing_sg[0].id
}
