variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "ap-southeast-1"
}

variable "create_eip" {
  description = "True or false to create Elastic IP"
  type        = bool
  default     = false
}

variable "eip_name" {
  description = "Name tag to assign to the Elastic IP"
  type        = string
  default     = "cldr-mngr-eip"
}

variable "eip_tags" {
  description = "Map of tags to apply to the key pair (owner and environment)"
  type        = map(string)
  default = {
    "owner"       = "kashu"
    "environment" = "your-environment"
  }
}
