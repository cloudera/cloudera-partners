# Outputs for the key pair module  

output "keypair_name" {
  value = var.create_keypair ? aws_key_pair.pvc_cluster_keypair[0].key_name : data.aws_key_pair.existing_keypair[0].key_name
}
