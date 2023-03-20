########################################################################
# 계정 및 리전 정보 조회
########################################################################
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

########################################################################
# 생성된 EKS cluster 정보 조회
########################################################################
data "aws_eks_cluster" "cluster" {
    name = var.cluster_name
}

########################################################################
# Local Variables
########################################################################
locals {
  cluster_nm = format("%s-%s", var.svr_nm, var.env)
  kubeconfig_data = {
    CLUSTER_NAME = data.aws_eks_cluster.cluster.name
    B64_CLUSTER_CA = data.aws_eks_cluster.cluster.certificate_authority.0.data
    API_SERVER_URL = data.aws_eks_cluster.cluster.endpoint
  }
}

########################################################################
# Amazon eks node AMI :: for launch template
########################################################################
data "aws_ami" "eks-worker" {
    filter {
        name = "name"
        values = ["amazon-eks-node-${data.aws_eks_cluster.cluster.version}-v*"]
    }
    most_recent = true
    owners = ["602401143452"] # Amazon EKS AMI Account ID
}

########################################################################
# EKS Worker Nodes Template :: for launch template
########################################################################
resource "aws_launch_template" "node" {
  name_prefix = local.cluster_nm

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size = 30
      volume_type = "gp2"
    }
  }

  credit_specification {
    cpu_credits = "standard"
  }

  ebs_optimized = true
  image_id = data.aws_ami.eks-worker.id
  # instance_type = var.instance_type
  key_name = var.key_name
  vpc_security_group_ids = [aws_security_group.node.id]
  # source_security_group_ids = [var.bastion_security_id]

  user_data = base64encode(templatefile("${path.module}/template/userdata.tpl", local.kubeconfig_data))

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = format("%s-%s", local.cluster_nm, "node-template")
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

########################################################################
# EKS Worker Nodes
########################################################################
resource "aws_eks_node_group" "node" {
  cluster_name = local.cluster_nm
  node_group_name = format("%s-%s", local.cluster_nm, "node")
  node_role_arn = aws_iam_role.node.arn
  subnet_ids = var.private_subnet_ids

  scaling_config {
    desired_size = var.min_size
    max_size = var.max_size
    min_size = var.min_size
  }

  // Worker Settings
  instance_types = [var.instance_type]
  disk_size      = 30
  
  # 1. used template
  # launch_template {
  #   name = aws_launch_template.node.name
  #   version = aws_launch_template.node.latest_version
  # }
  # 2. used managed ami
  # ami_type = "AL2_x86_64"
  # instance_types = [var.instance_type]
  # capacity_type = "ON_DEMAND"
  # disk_size = 30
  
  remote_access {
    ec2_ssh_key = var.key_name
    source_security_group_ids = [var.bastion_security_id]
  }

  update_config {
    max_unavailable = var.min_size
  }

  tags = {
    Name = format("%s-%s", local.cluster_nm, "node")
    Environment = var.env
    "kubernetes.io/cluster/${local.cluster_nm}" = "owned"
    propagate_at_launch = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.node
  ]
}

########################################################################
# Cluster Config template
########################################################################
data "template_file" "config" {
  template = file("${path.module}/template/config.tpl")
  vars = {
    certificate_data  = local.kubeconfig_data.B64_CLUSTER_CA
    cluster_endpoint  = local.kubeconfig_data.API_SERVER_URL
    aws_region        = data.aws_region.current.name
    cluster_name      = data.aws_eks_cluster.cluster.name
    account_id        = data.aws_caller_identity.current.account_id
  }
}
# 로컬에 config 파일 생성
resource "local_file" "config" {
  content  = data.template_file.config.rendered
  filename = "${path.root}/../../../../../${var.cluster_name}-config"
}
