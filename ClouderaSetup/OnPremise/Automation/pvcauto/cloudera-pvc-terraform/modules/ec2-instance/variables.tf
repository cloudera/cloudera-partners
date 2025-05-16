# # # Terraform module to support multiple EC2 instance groups with different configurations

# # variable "common_config" {
# #   description = "Common config shared by all instances"
# #   type = object({
# #     vpc_id            = string
# #     subnet_id         = string
# #     security_group_id = string
# #     key_name          = string
# #   })
# # }

variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "ap-southeast-1"
}

variable "vpc_id" {
  description = "VPC ID where the instances will be deployed"
  type        = string
  default     = "vpc-9d9385fa"
}

variable "subnet_id" {
  description = "Subnet ID where the instances will be deployed"
  type        = string
  default     = "subnet-6346ad2b"
}

variable "security_group_id" {
  description = "Security Group ID to associate with the instances"
  type        = string
  default     = "sg-0dbb6f79cba5ef701"
}

variable "key_name" {
  description = "Key pair name to use for the instances"
  type        = string
  default     = "kuldeep-pvc-session"
}

variable "pvc_cluster_tags" {
  description = "Tags to apply to all EC2 instances"
  type        = map(string)
  default = {
    owner       = "ksahu"
    environment = "development"
  }
}

variable "instance_groups" {
  description = "EC2 instance groups with individual configurations"
  type = map(object({
    count         = number
    ami           = string
    instance_type = string
    volume_size   = number
    tags          = map(string)
    user_data     = optional(string)
  }))
  default = {
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
}

variable "cldr_mngr_eip_enabled" {
  description = "True or false to create Elastic IP for Cloudera Manager"
  type        = bool
  default     = false
}

variable "cldr_mngr_eip_allocation_id" {
  description = "EIP Allocation ID for Cloudera Manager"
  type        = string
  default     = null
}
