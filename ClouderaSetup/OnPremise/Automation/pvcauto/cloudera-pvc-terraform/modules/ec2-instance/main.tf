# # # Placeholder for ec2-instance logic

locals {
  flattened_instances = flatten([
    for group_name, group_cfg in var.instance_groups : [
      for i in range(group_cfg.count) : {
        group         = group_name
        index         = i + 1
        name_tag      = "${group_cfg.tags["Name"]}-${i + 1}"
        ami           = group_cfg.ami
        instance_type = group_cfg.instance_type
        volume_size   = group_cfg.volume_size
        user_data     = lookup(group_cfg, "user_data", null)
        tags = merge(var.pvc_cluster_tags, group_cfg.tags, {
          Name  = "${group_cfg.tags["Name"]}-${i + 1}"
          Group = group_name
        })
      }
    ]
  ])
}

resource "aws_instance" "group_instances" {
  for_each = {
    for instance in local.flattened_instances :
    "${instance.group}-${instance.index}" => instance
  }

  ami                         = each.value.ami
  instance_type               = each.value.instance_type
  key_name                    = var.key_name
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [var.security_group_id]
  user_data                   = each.value.user_data
  associate_public_ip_address = true

  root_block_device {
    volume_size = each.value.volume_size
    volume_type = "gp3"
  }

  tags = each.value.tags
}

resource "aws_eip_association" "cldr_mngr" {
  for_each = var.cldr_mngr_eip_enabled ? {
    for k, inst in aws_instance.group_instances :
    k => inst if k == "cldr_mngr-1"
  } : {}

  instance_id   = each.value.id
  allocation_id = var.cldr_mngr_eip_allocation_id
}
