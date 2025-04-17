# Terraform Block
terraform {
  required_version = ">= 1.4.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.65.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 3.1.0" # Specify a version or leave out for latest
    }
  }
}
# Provider Block
provider "aws" {
  region = var.aws_region
  # profile = "default" 
}