# This module creates a VPC with public and private subnets.
#   enable_dns_support   = true
#   enable_dns_hostnames = true

# If create_vpc = true → use the public module
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  count = var.create_vpc ? 1 : 0

  name = var.vpc_name
  cidr = var.vpc_cidr_block

  azs             = var.azs
  private_subnets = var.private_subnets_cidr
  public_subnets  = var.public_subnets_cidr

  enable_nat_gateway = var.enable_nat_gateway
  enable_vpn_gateway = var.enable_vpn_gateway

  tags = merge(
    var.vpc_tags,
    {
      "created_by" = "Terraform"
    }
  )
}

# If create_vpc = false → fetch the default VPC
data "aws_vpc" "default" {
  count   = var.create_vpc ? 0 : 1
  default = true
}

data "aws_subnets" "default" {
  count = var.create_vpc ? 0 : 1
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default[0].id]
  }
}
