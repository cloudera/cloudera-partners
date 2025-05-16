# Variables for Cloudera PVC Cluster Terraform Module
# This module creates a Cloudera PVC cluster on AWS using Terraform.
# It includes the creation of EC2 instances, VPC, security groups, and other necessary resources.
# The module is designed to be reusable and configurable through input variables.
# The variables are defined below with their descriptions, types, and default values where applicable.
# The module is intended for use in a development environment and can be customized for production use.

# Common Variables
variable "aws_region" {
  description = "AWS region to deploy pvc cluster infra"
  type        = string
  default     = "ap-southeast-1"
}

variable "pvc_cluster_tags" {
  description = "Tags to apply to all EC2 instances"
  type        = map(string)
  default = {
    owner       = "ksahu"
    environment = "development"
  }
}

# Keypair Variables
variable "create_keypair" {
  description = "Flag to decide whether to create a new key pair or use an existing one"
  type        = bool
  default     = true
}

variable "keypair_name" {
  description = "Name of the key pair"
  type        = string
}

variable "existing_keypair_name" {
  description = "The name of the existing key pair (if using an existing one)"
  type        = string
  default     = ""
}

# Security Group Variables
variable "sg_name" {
  description = "Name of the security group"
  type        = string
  default     = "pvc_cluster_sg"
}

variable "allow_all" {
  description = "whether to allow all ingress traffic"
  type    = bool
  default = true
}

variable "allowed_ports" {
  description = "List of allowed ports"
  type        = list(number)
  default     = [0]
}

variable "allowed_cidrs" {
  description = "List of CIDR blocks allowed to access the ports"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "create_new_sg" {
  description = "Flag to decide whether to create a new security group or use an existing one"
  type        = bool
  default     = true
}

variable "existing_sg" {
  description = "The name of the existing security group (if using an existing one)"
  type        = string
  default     = ""
}

# Elastic IP Variables
variable "create_eip" {
  description = "Flag to decide whether to create an eip for cloudera manager"
  type        = bool
  default     = true
}

variable "cldr_eip_name" {
  description = "Name of the elastic ip"
  type        = string
}

# VPC Variables
variable "create_vpc" {
  description = "Whether to create a new VPC or use the default one"
  type        = bool
  default     = false
}

variable "vpc_name" {
  description = "Name of new VPC or use the default one"
  type        = string
  default     = "cloudera-vpc"
}

variable "vpc_tags" {
  description = "Map of tags to apply to the key pair (owner and environment)"
  type        = map(string)
  default = {
    owner       = "ksahu"
    environment = "development"
  }
}

variable "vpc_cidr_block" {
  type    = string
  default = "10.0.0.0/16"
}

variable "azs" {
  type    = list(string)
  default = []
}

variable "private_subnets_cidr" {
  type    = list(string)
  default = []
}

variable "public_subnets_cidr" {
  type    = list(string)
  default = []
}

variable "enable_nat_gateway" {
  type    = bool
  default = false
}

variable "enable_vpn_gateway" {
  type    = bool
  default = false
}

# EC2 Variables
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