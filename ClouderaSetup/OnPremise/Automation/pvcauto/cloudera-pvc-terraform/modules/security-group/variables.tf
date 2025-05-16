# Variables for the security group module
variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "ap-southeast-1"
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

variable "sg_name" {
  description = "Name of the security group"
  type        = string
  default     = "pvc_cluster_sg"
}

variable "sg_description" {
  description = "Description of the security group"
  type        = string
  default     = "Cloudera security group"

}

variable "vpc_id" {
  description = "The VPC ID where the security group will be created"
  type        = string
  default     = "vpc-9d9385fa"
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

variable "sg_tags" {
  description = "Tags to apply to the security group"
  type        = map(string)
  default = {
    "owner"       = "kashu"
    "environment" = "your-environment"
  }
}
