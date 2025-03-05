variable "log_bucket_name" {
  description = "Name of the instance"
  type        = string
}

variable "aws_region" {
  description = "AWS region to create resources"
  type        = string
  default     = "us-east-1"
}