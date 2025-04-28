#Get the latest ubuntu 22.04 LTS version
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Only create a key pair if none is passed
resource "tls_private_key" "generated" {
  algorithm = "RSA"
  rsa_bits  = 4096
  count     = var.key_name == "" ? 1 : 0
}

resource "aws_key_pair" "generated" {
  key_name   = "generated-${var.instance_name}"
  public_key = tls_private_key.generated[0].public_key_openssh
  count      = var.key_name == "" ? 1 : 0
}

# Save private key locally (e.g., to use via Ansible or SSH)
resource "local_file" "private_key" {
  content  = tls_private_key.generated[0].private_key_pem
  filename = "${path.module}/generated-${var.instance_name}.pem"
  file_permission = "0600"
  count    = var.key_name == "" ? 1 : 0
}

# Pick final key_name (input or generated)
locals {
  final_key_name = var.key_name != "" ? var.key_name : aws_key_pair.generated[0].key_name
}

# Default VPC (used if no vpc_id provided)
data "aws_vpc" "default" {
  count   = var.vpc_id == "" ? 1 : 0
  default = true
}

# Final VPC ID logic
locals {
  final_vpc_id = var.vpc_id != "" ? var.vpc_id : data.aws_vpc.default[0].id
}

# Get subnets for the chosen VPC
data "aws_subnets" "available" {
  filter {
    name   = "vpc-id"
    values = [local.final_vpc_id]
  }
}

resource "aws_security_group" "ssh" {
  name        = "allow_ssh_from_my_ip"
  description = "Allow SSH from automation host"
  vpc_id      = local.final_vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.local_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "my_instance" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name               = local.final_key_name
  subnet_id              = data.aws_subnets.available.ids[0]
  vpc_security_group_ids = [aws_security_group.ssh.id]
  tags = {
    "Name" = var.instance_name
  }

  # Block device mapping to create a 100 GB volume
  root_block_device {
    volume_size           = 100
    volume_type           = "gp2"
    delete_on_termination = true
  }
}

