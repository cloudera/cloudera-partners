# This module creates an Elastic IP in AWS.
resource "aws_eip" "this" {
  count  = var.create_eip == true ? 1 : 0
  domain = "vpc"

  tags = merge(
    var.eip_tags,
    {
      "Name"      = var.eip_name,
      "CreatedBy" = "Terraform"
    }
  )
}
