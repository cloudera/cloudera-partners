# Variables for VPC module
variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "ap-southeast-1"
}

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
