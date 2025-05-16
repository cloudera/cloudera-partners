output "instance_public_ips" {
  description = "Public IPs of all created EC2 instances"
  value       = concat(
    aws_instance.master.*.public_ip,
    aws_instance.worker.*.public_ip,
    aws_instance.data_service.*.public_ip
  )
}

output "instance_private_ips" {
  description = "Private IPs of all created EC2 instances"
  value       = concat(
    aws_instance.master.*.private_ip,
    aws_instance.worker.*.private_ip,
    aws_instance.data_service.*.private_ip
  )
}

output "instance_names" {
  description = "Names of all created EC2 instances"
  value = concat(
    [for inst in aws_instance.master     : inst.tags["Name"]],
    [for inst in aws_instance.worker     : inst.tags["Name"]],
    [for inst in aws_instance.data_service : inst.tags["Name"]]
  )
}
