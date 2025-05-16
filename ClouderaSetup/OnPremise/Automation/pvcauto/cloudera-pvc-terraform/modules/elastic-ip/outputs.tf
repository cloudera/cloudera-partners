
output "eip_public_ip" {
  description = "The public IP address of the Elastic IP"
  value       = var.create_eip ? aws_eip.this[*].public_ip : null
}

output "eip_allocation_id" {
  value       = aws_eip.this[0].id
  description = "The Allocation ID of the Elastic IP"
}
