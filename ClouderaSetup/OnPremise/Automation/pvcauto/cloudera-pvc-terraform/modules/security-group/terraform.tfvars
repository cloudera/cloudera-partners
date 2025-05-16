# Common: vars
aws_region = "ap-southeast-1"

# Tags to apply to the key pair (e.g., owner and environment)
sg_tags = {
  owner       = "ksahu" # Set your owner tag
  environment = "development"   # Set your environment tag
}

# Security group creation: vars
sg_description = "Cloudera security group"
allowed_cidrs  = ["0.0.0.0/0"]
allow_all      = true         # Set true to allow all inbound traffic
allowed_ports  = [22, 443, 80, 7180, 7183, 7182]
vpc_id         = "vpc-9d9385fa"
sg_name        = "pvc_cluster_sg"
create_new_sg  = true
existing_sg    = "sg-237b7452"
