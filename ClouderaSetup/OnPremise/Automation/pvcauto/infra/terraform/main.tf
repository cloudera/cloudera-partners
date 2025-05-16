provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.aws_region
}

# 1) Custom VPC if none provided
resource "aws_vpc" "custom" {
  count      = var.vpc_id == "" ? 1 : 0
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "${var.deployment_mode}-vpc"
  }
}

# 2) Default VPC lookup
data "aws_vpc" "default" {
  default = true
}

# 3) Availability zones for custom subnet
data "aws_availability_zones" "available" {
  state = "available"
}

# 4) Custom subnet if we created a VPC
resource "aws_subnet" "custom_subnet" {
  count             = length(aws_vpc.custom) > 0 ? 1 : 0
  vpc_id            = aws_vpc.custom[0].id
  cidr_block        = "10.0.1.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "${var.deployment_mode}-subnet"
  }
}

# 5) Compute locals (all on one line each)
locals {
  deployment_slug  = lower(replace(var.deployment_mode, " ", ""))
  selected_vpc     = var.vpc_id != "" ? var.vpc_id : (length(aws_vpc.custom) > 0 ? aws_vpc.custom[0].id : data.aws_vpc.default.id)
  selected_subnet  = length(aws_subnet.custom_subnet) > 0 ? aws_subnet.custom_subnet[0].id : data.aws_subnets.existing.ids[0]
}

# 6) Existing subnets for the chosen VPC
data "aws_subnets" "existing" {
  filter {
    name   = "vpc-id"
    values = [local.selected_vpc]
  }
}

# 7) SSH security group
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh1"
  description = "Allow SSH inbound"
  vpc_id      = local.selected_vpc

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 8) Master nodes
resource "aws_instance" "master" {
  count                  = var.master_count
  ami                    = var.ami_id
  instance_type          = var.master_type
  key_name               = var.key_name
  subnet_id              = local.selected_subnet
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  tags = {
    Name = "${local.deployment_slug}-${var.master_prefix}${count.index}"
  }
}

# 9) Worker nodes
resource "aws_instance" "worker" {
  count                  = var.worker_count
  ami                    = var.ami_id
  instance_type          = var.worker_type
  key_name               = var.key_name
  subnet_id              = local.selected_subnet
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  tags = {
    Name = "${local.deployment_slug}-${var.worker_prefix}${count.index}"
  }
}

# 10) Data-service nodes (optional)
resource "aws_instance" "data_service" {
  count                  = var.data_service_count
  ami                    = var.ami_id
  instance_type          = var.data_service_type
  key_name               = var.key_name
  subnet_id              = local.selected_subnet
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  tags = {
    Name = "${local.deployment_slug}-${var.data_service_prefix}${count.index}"
  }
}

# 11) Elastic IPs if requested
resource "aws_eip" "eip_master" {
  count    = var.required_elastic_ip ? var.master_count : 0
  instance = aws_instance.master[count.index].id
  domain   = "vpc"
}

resource "aws_eip" "eip_worker" {
  count    = var.required_elastic_ip ? var.worker_count : 0
  instance = aws_instance.worker[count.index].id
  domain   = "vpc"
}

resource "aws_eip" "eip_data" {
  count    = var.required_elastic_ip ? var.data_service_count : 0
  instance = aws_instance.data_service[count.index].id
  domain   = "vpc"
}
