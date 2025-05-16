# Key Pair Module
module "key-pair" {
  source                = "./modules/key-pair"
  create_keypair        = var.create_keypair
  keypair_name          = var.keypair_name
  existing_keypair_name = var.existing_keypair_name
  keypair_tags          = var.pvc_cluster_tags
}

# VPC Module
module "vpc" {
  source               = "./modules/vpc"
  create_vpc           = var.create_vpc
  vpc_cidr_block       = var.vpc_cidr_block
  azs                  = var.azs
  private_subnets_cidr = var.private_subnets_cidr
  public_subnets_cidr  = var.public_subnets_cidr
  enable_nat_gateway   = var.enable_nat_gateway
  enable_vpn_gateway   = var.enable_vpn_gateway
  vpc_name             = var.vpc_name
  vpc_tags             = var.pvc_cluster_tags
}

# Security Group Module
module "security_group" {
  source         = "./modules/security-group"
  sg_name        = var.sg_name
  sg_description = "Allow traffic for the VPC"
  vpc_id         = module.vpc.vpc_id
  allow_all      = var.allow_all
  allowed_ports  = var.allowed_ports
  allowed_cidrs  = var.allowed_cidrs
  sg_tags        = var.pvc_cluster_tags
  create_new_sg  = var.create_new_sg
  existing_sg    = var.existing_sg
  depends_on = [
    module.vpc
  ]
}

# Elastic IP Module
module "elastic-ip" {
  source     = "./modules/elastic-ip"
  create_eip = var.create_eip
  eip_name   = var.cldr_eip_name
  eip_tags   = var.pvc_cluster_tags
}

# EC2 Instances Module
module "ec2_instances" {
  source                      = "./modules/ec2-instance"
  vpc_id                      = module.vpc.vpc_id
  subnet_id                   = module.vpc.subnet_ids[0] # or loop if needed
  security_group_id           = module.security_group.security_group_id
  key_name                    = module.key-pair.keypair_name
  pvc_cluster_tags            = var.pvc_cluster_tags
  instance_groups             = var.instance_groups
  cldr_mngr_eip_enabled       = var.create_eip
  cldr_mngr_eip_allocation_id = module.elastic-ip.eip_allocation_id
  depends_on = [
    module.key-pair,
    module.security_group,
    module.vpc
  ]
}

# Use `locals` to dynamically update the public IPs if necessary
locals {
  # Access the public IPs from EC2 instances
  original_public_ips = module.ec2_instances.public_ips

  # Conditionally replace Cloudera Manager's public IP with Elastic IP
  final_public_ips = merge(
    local.original_public_ips,
    var.create_eip && contains(keys(local.original_public_ips), "cldr_mngr-1") ? {
      "cldr_mngr-1" = module.elastic-ip.eip_public_ip[0]
    } : {}
  )
}