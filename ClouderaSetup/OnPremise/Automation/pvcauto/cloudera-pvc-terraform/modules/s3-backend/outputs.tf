output "s3_bucket_name" {
  description = "Name of the created S3 bucket"
  value       = aws_s3_bucket.tf_state.id
}

output "dynamodb_table_name" {
  description = "Name of the created DynamoDB table"
  value       = var.create_dynamodb_table ? aws_dynamodb_table.tf_lock[*].id : null
}
