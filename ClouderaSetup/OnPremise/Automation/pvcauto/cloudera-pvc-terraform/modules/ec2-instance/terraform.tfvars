# Common: vars
aws_region = "ap-southeast-1"

# Tags to apply to the key pair (e.g., owner and environment)
pvc_cluster_tags = {
  owner       = "ksahu"       # Set your owner tag
  environment = "development" # Set your environment tag
}

# EC2 Groups Definition: vars
vpc_id                      = "vpc-9d9385fa"
subnet_id                   = "subnet-6346ad2b"
security_group_id           = "sg-0dbb6f79cba5ef701"
key_name                    = "kuldeep-pvc-session"
cldr_mngr_eip_enabled       = false
cldr_mngr_eip_allocation_id = "eipalloc-0c3f1a2b4d5e6f7a8"
instance_groups = {
  cldr_mngr = {
    count         = 1
    ami           = "ami-06dc977f58c8d7857"
    instance_type = "t3.medium"
    volume_size   = 30
    tags          = { Name = "cldr-mngr" }
  },
  ipa_server = {
    count         = 1
    ami           = "ami-06dc977f58c8d7857"
    instance_type = "t3.medium"
    volume_size   = 30
    tags          = { Name = "ipa-server" }
  },
  pvcbase_master = {
    count         = 1
    ami           = "ami-06dc977f58c8d7857"
    instance_type = "t3.large"
    volume_size   = 50
    tags          = { Name = "pvcbase-master" }
  },
  pvcbase_worker = {
    count         = 1
    ami           = "ami-06dc977f58c8d7857"
    instance_type = "t3.large"
    volume_size   = 50
    tags          = { Name = "pvcbase-worker" }
  },
  pvcecs_master = {
    count         = 1
    ami           = "ami-06dc977f58c8d7857"
    instance_type = "t3.xlarge"
    volume_size   = 100
    tags          = { Name = "pvcecs-master" }
  },
  pvcecs_worker = {
    count         = 1
    ami           = "ami-06dc977f58c8d7857"
    instance_type = "t3.xlarge"
    volume_size   = 100
    tags          = { Name = "pvcecs-worker" }
  }
}
