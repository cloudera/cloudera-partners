output "public_ip" {
  value = aws_instance.my_instance.public_ip
}

output "instance_id" {
  value = aws_instance.my_instance.id
}

output "ssh_command" {
  value = "ssh -i ~/.ssh/YOUR_KEY.pem ubuntu@${aws_instance.my_instance.public_ip}"
}
