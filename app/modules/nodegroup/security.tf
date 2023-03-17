###################################################################################
# Security Group :: EKS Worker Nodes
# 참조URL) https://docs.aws.amazon.com/eks/latest/userguide/sec-group-reqs.html
###################################################################################
# Security Group
resource "aws_security_group" "node" {
  name = format("%s-%s", var.svr_nm, "node")
  vpc_id = var.vpc_id

  tags = {
    Name = format("%s-%s", var.svr_nm, "node")
    Environments = var.env
    "kubernetes.io/cluster/${local.cluster_nm}" = "owned"
    "karpenter.sh/discovery" = local.cluster_nm
  }
}

# Security Group Rule :: Self Inbound
resource "aws_security_group_rule" "node_ingress_self" {
  type = "ingress"
  security_group_id = aws_security_group.node.id
  source_security_group_id = aws_security_group.node.id

  from_port = var.ports.any_port      # 0
  to_port = var.ports.node_to_port    # 65535
  protocol = var.ports.any_protocol   # -1
}

# Security Group Rule :: ALL outbound
resource "aws_security_group_rule" "node_egress_all" {
  type = "egress"
  security_group_id = aws_security_group.node.id

  from_port = var.ports.any_port      # 0
  to_port = var.ports.any_port        # 0
  protocol = var.ports.any_protocol   # -1
  cidr_blocks = var.ports.all_ips     # 0.0.0.0/0
}

# Security Group Rule :: Cluster Inbound
resource "aws_security_group_rule" "node_ingress_cluster" {
  type = "ingress"
  security_group_id = aws_security_group.node.id
  source_security_group_id = var.cluster_security_id

  from_port = var.ports.node_from_port    # 1025
  to_port = var.ports.node_to_port        # 65535
  protocol = var.ports.tcp_protocol       # tcp
}

###################################################################################
# EKS 마스터 노드에서 Node 엑세스
###################################################################################
resource "aws_security_group_rule" "cluster-ingress-node-https" {
  type = "ingress"
  security_group_id = var.cluster_security_id
  source_security_group_id = aws_security_group.node.id

  from_port = var.ports.https_port    # 443
  to_port = var.ports.https_port      # 443
  protocol = var.ports.tcp_protocol   # 443
}

###################################################################################
# Bastion Host에서 Node 엑세스
###################################################################################
resource "aws_security_group_rule" "bastion-ingress-node-ssh" {
  type = "ingress"
  security_group_id = var.bastion_security_id
  source_security_group_id = aws_security_group.node.id

  from_port = var.ports.ssh_port    # 22
  to_port = var.ports.ssh_port      # 22
  protocol = var.ports.tcp_protocol # tcp
}
