variable "aws_region" {
  description = "AWS region to deploy in"
  type        = string
  default     = "ap-southeast-1"
}

variable "aws_profile" {
  description = "AWS CLI profile to use"
  type        = string
  default     = "default"
}

variable "vpc_id" {
  description = "VPC ID to launch instance in. If not provided, use default VPC."
  type        = string
  default     = ""
}

variable "key_name" {
  description = "AWS key pair name to use for SSH access"
  type        = string
  default     = ""
}

variable "local_ip" {
  description = "IPV4 Address User's Local Machine"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "m5.2xlarge"
}
variable "instance_name" {
  description = "name of the EC2 instance"
  type        = string
  default     = "DIM_Operatorstest"
}
