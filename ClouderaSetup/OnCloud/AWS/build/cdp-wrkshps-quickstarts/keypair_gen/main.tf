# Terraform Block
terraform {
  required_version = ">= 1.4.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.65.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 3.1.0" # Specify a version or leave out for latest
    }
  }
}
# Provider Block
provider "aws" {
  region = var.aws_region
  # profile = "default" 
}

# ------- Create SSH Keypair if input aws_key_pair variable is not specified
locals {
  # flag to determine if keypair should be created
  create_keypair = var.aws_key_pair == "" ? true : false

  # key pair value
  aws_key_pair = (
    local.create_keypair == false ?
    var.aws_key_pair :
    aws_key_pair.kc_keypair[0].key_name
  )
}
# Create and save a RSA key
resource "tls_private_key" "kc_private_key" {
  count     = local.create_keypair ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}
# Save the private key to <keypair_name>-keypair.pem
resource "local_sensitive_file" "pem_file" {
  count                = local.create_keypair ? 1 : 0
  filename             = "${var.keypair_name}-keypair.pem"
  file_permission      = "600"
  directory_permission = "700"
  content              = tls_private_key.kc_private_key[0].private_key_pem
}
# Create an AWS EC2 keypair from the generated public key
resource "aws_key_pair" "kc_keypair" {
  count      = local.create_keypair ? 1 : 0
  key_name   = "${var.keypair_name}-keypair"
  public_key = tls_private_key.kc_private_key[0].public_key_openssh
}
