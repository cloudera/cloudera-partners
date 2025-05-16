variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "ap-southeast-1"
}

variable "create_keypair" {
  description = "Flag to decide whether to create a new key pair or use an existing one"
  type        = bool
  default     = true
}

variable "existing_keypair_name" {
  description = "The name of the existing key pair (if using an existing one)"
  type        = string
  default     = "kuldeep-pvc-session" # Note: without the .pem
}

variable "keypair_name" {
  description = "Name of the key pair"
  type        = string
  default     = "pvc-new-keypair"
}

variable "keypair_tags" {
  description = "Map of tags to apply to the key pair (owner and environment)"
  type        = map(string)
  default = {
    "owner"       = "ksahu"
    "environment" = "development"
  }
}

variable "public_key_path" {
  description = "Path to the public key file for an existing key pair"
  type        = string
  default     = ""
}
