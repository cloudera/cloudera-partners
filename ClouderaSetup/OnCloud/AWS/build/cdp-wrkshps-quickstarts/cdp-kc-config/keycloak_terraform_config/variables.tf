variable workshop_name {
  description = "name_prefix Of the EC2 instance"
  type = string
  default = "keycloak-server"
}

variable "aws_region" {
  description = "AWS Region In which Resources Will Be Deployed"
  type = string
  default = "ap-southeast-1"  
}

variable "instance_type" {
  description = "Instance Type "
  type = string
  default = "t2.xlarge"  
}

variable "instance_keypair" {
  description = "SSH KeyPair For EC2 Instance"
  type = string
  default = "aktpsedaily"  
}

variable "kc_security_group" {
  description = "Security Group Name For EC2"
  type = string
  default = "hol-default-sg"
}
variable "local_ip" {
  description = "IPV4 Address User's Local Machine"
  type = string
  default = "0.0.0.0/0"
}
variable "keycloak_admin_password" {
  description = "admin password for keycloak"
  type = string
}
variable "amis" {
  type = map(string)
  default = {
    "us-east-2" = "ami-0f30a9c3a48f3fa79"
    "us-east-1" = "ami-0e001c9271cf7f3b9"
    "us-west-1" = "ami-036cafe742923b3d9"
    "us-west-2" = "ami-03c983f9003cb9cd1"
    "ap-south-1" = "ami-05e00961530ae1b55"
    "ap-southeast-1" = "ami-0be48b687295f8bd6"
    "ap-southeast-2" = "ami-01ed8ade75d4eee2f"
    "eu-central-1" = "ami-026c3177c9bd54288"
    "eu-west-1" = "ami-0607a9783dd204cae"
    "eu-west-2" = "ami-09627c82937ccdd6d"
  }
}
