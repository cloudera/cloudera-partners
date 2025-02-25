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
  }
}
