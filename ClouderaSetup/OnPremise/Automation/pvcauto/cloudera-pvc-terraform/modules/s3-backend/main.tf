resource "aws_s3_bucket" "tf_state" {
  bucket = var.bucket_name
  lifecycle {
    prevent_destroy = true
  }
  tags = merge(
    var.s3_backend_tags,
    {
      "created_by" = "Terraform"
    }
  )
}

resource "aws_s3_bucket_versioning" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_dynamodb_table" "tf_lock" {
  count        = var.create_dynamodb_table ? 1 : 0
  name         = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
  tags = merge(
    var.s3_backend_tags,
    {
      "created_by" = "Terraform"
    }
  )
}
