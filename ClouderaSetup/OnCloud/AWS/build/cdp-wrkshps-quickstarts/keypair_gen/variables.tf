# Variables
variable "aws_region" {
  description = "AWS region to create resources"
  type        = string
  default     = "us-east-1"
}

variable "keypair_name" {
  description = "Name of the instance"
  type        = string
}

variable "aws_key_pair" {
  description = "Optional AWS key pair name. If empty, a new key pair will be created."
  type        = string
  default     = ""
}

