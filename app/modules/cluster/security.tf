###################################################################################
# Security Group :: EKS Cluster
# 참조URL) https://docs.aws.amazon.com/eks/latest/userguide/sec-group-reqs.html
###################################################################################
# Security Group
resource "aws_security_group" "cluster" {
  name = format("%s-%s", var.svr_nm, "sg")
  vpc_id = var.vpc_id

  tags = {
    Name = format("%s-%s", var.svr_nm, "sg")
    Environments = var.env
    "karpenter.sh/discovery" = local.cluster_nm
  }
}

# Security Group Rule :: Node Inbound
resource "aws_security_group_rule" "cluster_ingress_workstation_https" {
  type = "ingress"
  security_group_id = aws_security_group.cluster.id
  cidr_blocks = var.workstation_cidr

  from_port = var.ports.https_port    # 443
  to_port = var.ports.https_port      # 443
  protocol = var.ports.tcp_protocol
}

# Security Group Rule :: ALL outbound
resource "aws_security_group_rule" "cluster_egress_all" {
  type = "egress"
  security_group_id = aws_security_group.cluster.id

  from_port = var.ports.any_port
  to_port = var.ports.any_port
  protocol = var.ports.any_protocol
  cidr_blocks = var.ports.all_ips
}