# Common: vars
aws_region = "ap-southeast-1"

# Tags to apply to the key pair (e.g., owner and environment)
vpc_tags = {
  owner       = "ksahu" # Set your owner tag
  environment = "development"   # Set your environment tag
}

# VPC creation: vars
create_vpc           = true
vpc_name             = "cloudera-vpc"
vpc_cidr_block       = "10.0.0.0/16"
azs                  = ["ap-southeast-1a", "ap-southeast-1b"]
public_subnets_cidr  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnets_cidr = []
enable_nat_gateway   = false
enable_vpn_gateway   = false
