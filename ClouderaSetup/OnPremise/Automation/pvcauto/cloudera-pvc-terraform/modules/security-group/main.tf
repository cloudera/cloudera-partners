# Use existing security group if not creating a new one
data "aws_security_group" "existing_sg" {
  count = var.create_new_sg ? 0 : 1
  id    = var.existing_sg
}

resource "aws_security_group" "vpc_sg" {
  count       = var.create_new_sg ? 1 : 0
  name        = var.sg_name
  description = var.sg_description
  vpc_id      = var.vpc_id

  lifecycle {
    create_before_destroy = true
  }

  # Ingress rule for allowing all traffic (if allow_all is true)
  dynamic "ingress" {
    for_each = var.allow_all ? [1] : []
    content {
      description = "Allow all inbound traffic"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = var.allowed_cidrs
    }
  }

  # Ingress rule for specific TCP ports (if allow_all is false)
  dynamic "ingress" {
    for_each = var.allow_all ? [] : var.allowed_ports
    content {
      description = "Allow TCP traffic on port ${ingress.value}"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = var.allowed_cidrs
    }
  }

  # Internal traffic rule
  ingress {
    description = "Allow all internal VPC traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  # Egress rule
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.sg_tags,
    {
      "created_by" = "Terraform"
    }
  )
}
