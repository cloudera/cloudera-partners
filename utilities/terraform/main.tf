module "ec2" {
  source    = "./ec2"
  vpc_id    = var.vpc_id
  key_name  = var.key_name
  instance_name = var.instance_name
  local_ip = var.local_ip
}
