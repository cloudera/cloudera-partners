# Terraform Block
terraform {
  required_version = ">= 1.4.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.65.0"
    }
  }
}
# Provider Block
provider "aws" {
  region = var.aws_region
  # profile = "default" 
}

resource "aws_s3_bucket_lifecycle_configuration" "log_lifecycle_policy" {
  bucket = var.log_bucket_name

  rule {
    id     = "delete_logs_after_15_days"
    status = "Enabled"

    filter {
      prefix = "logs/"
    }

    expiration {
      days = 15
    }
    noncurrent_version_expiration {
      noncurrent_days = 15
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
  # Rule 2: Remove expired delete markers (helps in bucket deletion)
  rule {
    id     = "remove_expired_delete_markers"
    status = "Enabled"

    filter {
      prefix = "logs/"
    }

    expiration {
      expired_object_delete_marker = true
    }
  }
}
