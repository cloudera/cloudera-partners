variable "instance_name" {
  description = "name of the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "m5.2xlarge"
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
  default     = ""
}

variable "vpc_id" {
  description = "Optional VPC ID. If not set, default VPC will be used."
  type        = string
  default     = ""
}

variable "aws_region" {
  description = "AWS region to deploy in"
  type        = string
  default     = "ap-southeast-1"
}

variable "local_ip" {
  description = "IPV4 Address User's Local Machine"
  type        = string
}