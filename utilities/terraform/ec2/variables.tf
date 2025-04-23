variable "instance_name" {
  description = "name of the EC2 instance"
  type        = string
  default     = "DIM_Operatorstest"
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

variable "local_ip" {
  description = "IPV4 Address User's Local Machine"
  type        = string
}
