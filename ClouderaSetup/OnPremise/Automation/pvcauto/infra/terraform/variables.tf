variable "aws_access_key" {
  description = "AWS access key"
  type        = string
}

variable "aws_secret_key" {
  description = "AWS secret key"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "deployment_mode" {
  description = "Deployment mode label"
  type        = string
}

variable "ami_id" {
  description = "AMI to use for all nodes"
  type        = string
}

variable "instance_count" {
  description = "Total number of instances (master+worker+data)"
  type        = number
}

variable "key_name" {
  description = "SSH key pair name (without .pem)"
  type        = string
}

variable "vpc_id" {
  description = "Existing VPC ID (empty to create or use default)"
  type        = string
}

variable "required_elastic_ip" {
  description = "Whether to allocate Elastic IPs for each instance"
  type        = bool
}

variable "master_count" {
  description = "Number of master nodes"
  type        = number
}

variable "master_prefix" {
  description = "Name prefix for master nodes"
  type        = string
}

variable "master_type" {
  description = "Instance type for master nodes"
  type        = string
}

variable "worker_count" {
  description = "Number of worker nodes"
  type        = number
}

variable "worker_prefix" {
  description = "Name prefix for worker nodes"
  type        = string
}

variable "worker_type" {
  description = "Instance type for worker nodes"
  type        = string
}

variable "data_service_count" {
  description = "Number of data-service nodes (optional)"
  type        = number
}

variable "data_service_prefix" {
  description = "Name prefix for data-service nodes"
  type        = string
}

variable "data_service_type" {
  description = "Instance type for data-service nodes"
  type        = string
}
