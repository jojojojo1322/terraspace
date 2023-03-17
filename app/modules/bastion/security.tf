###################################################################################
# Security Group :: Bastion Host
###################################################################################
# security group :: bastion host
resource "aws_security_group" "bastion" {
  name = format("%s-%s", var.svr_nm, "bastion")
  vpc_id = var.vpc_id

  tags = {
    Name = format("%s-%s", var.svr_nm, "bastion")
    Environments = var.env
  }
}

# security group rule :: inbound
resource "aws_security_group_rule" "bastion_ingress_ssh" {
  type = "ingress"
  security_group_id = aws_security_group.bastion.id

  from_port = var.ports.ssh_port
  to_port = var.ports.ssh_port
  protocol = var.ports.tcp_protocol
  cidr_blocks = var.ports.all_ips
}

# security group rule :: outbound
resource "aws_security_group_rule" "bastion_egress_all" {
  type = "egress"
  security_group_id = aws_security_group.bastion.id

  from_port = var.ports.any_port
  to_port = var.ports.any_port
  protocol = var.ports.any_protocol
  cidr_blocks = var.ports.all_ips
}

###################################################################################
# TLS Private key
###################################################################################
resource "tls_private_key" "bastion" {
  algorithm = "RSA"
  rsa_bits = 4096
}

###################################################################################
# AWS KEY PAIR
###################################################################################
resource "aws_key_pair" "bastion" {
  key_name = "bastion_ssh_key"
  public_key = tls_private_key.bastion.public_key_openssh
}

# local key file
resource "local_file" "bastion" {
  depends_on = [tls_private_key.bastion]
  content = tls_private_key.bastion.private_key_pem
  filename = "${path.root}/../../../../../topas.pem"
}