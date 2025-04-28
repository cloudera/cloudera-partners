output "public_ip" {
  value = aws_instance.my_instance.public_ip
}

output "instance_id" {
  value = aws_instance.my_instance.id
}

# Output the instance name
output "instance_name" {
  value = aws_instance.my_instance.tags["Name"]
}

output "ssh_command" {
  value = "ssh -i ~/.ssh/YOUR_KEY.pem ubuntu@${aws_instance.my_instance.public_ip}"
}
