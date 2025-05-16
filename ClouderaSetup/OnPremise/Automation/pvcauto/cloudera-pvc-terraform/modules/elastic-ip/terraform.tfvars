# Common: vars
aws_region = "ap-southeast-1"

# Tags to apply to the key pair (e.g., owner and environment)
eip_tags = {
  owner       = "ksahu" # Set your owner tag
  environment = "development"   # Set your environment tag
}

# EIP creation: vars
create_eip = true
eip_name   = "cldr-mngr-eip"
