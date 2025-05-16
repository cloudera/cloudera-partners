terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # backend "s3" {
  #   bucket = "pvc-cluster-terraform-backend"     # Replace with your S3 bucket name
  #   # dynamodb_table = "pvc-terraform-lock-table"
  #   use_lockfile = true                          # S3 Native Locking
  #   key          = "pvc_setup/terraform.tfstate" # Path where the state file will be stored inside the bucket
  #   region       = "ap-southeast-1"              # AWS region of the S3 bucket
  # }
}