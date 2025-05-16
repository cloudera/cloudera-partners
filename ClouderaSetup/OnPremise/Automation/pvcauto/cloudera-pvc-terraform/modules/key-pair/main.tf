# This module manages the creation of an SSH key pair for accessing the Cloudera PVC cluster.

# If using an existing keypair, don't create any resources
data "aws_key_pair" "existing_keypair" {
  count    = var.create_keypair == false ? 1 : 0
  key_name = var.existing_keypair_name
}

# If creating a new keypair, generate an RSA private key
resource "tls_private_key" "pvc_private_key" {
  count     = var.create_keypair == true ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

# If creating a new keypair, save the private key to a file
resource "local_sensitive_file" "pem_file" {
  count                = var.create_keypair == true ? 1 : 0
  filename             = "${var.keypair_name}.pem"
  file_permission      = "600"
  directory_permission = "700"
  content              = tls_private_key.pvc_private_key[0].private_key_pem
}

# If creating a new keypair, create the key pair in AWS
resource "aws_key_pair" "pvc_cluster_keypair" {
  count      = var.create_keypair == true ? 1 : 0
  key_name   = var.keypair_name
  public_key = tls_private_key.pvc_private_key[0].public_key_openssh

  # Adding tags to the key pair
  tags = merge(
    var.keypair_tags,
    {
      "created_by" = "Terraform"
    }
  )
}
