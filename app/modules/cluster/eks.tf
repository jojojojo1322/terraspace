###############################################################
# Local Variables
###############################################################
locals {
  cluster_nm = format("%s-%s", var.svr_nm, var.env)
}

########################################################################
# EKS Cluster 생성
########################################################################
resource "aws_eks_cluster" "cluster" {
  name = local.cluster_nm
  role_arn = aws_iam_role.cluster.arn
  version = var.cluster_version
  enabled_cluster_log_types = ["api","audit","authenticator","controllerManager","scheduler"]

  vpc_config {
    security_group_ids = [aws_security_group.cluster.id]
    subnet_ids = concat(var.public_subnet_ids, var.private_subnet_ids)

    endpoint_private_access = true
    endpoint_public_access = true
    public_access_cidrs = ["0.0.0.0/0"]
  }

  encryption_config {
    provider {
      key_arn = var.kms_key_arn
    }
    resources = ["secrets"]
  }

  timeouts {
    create = "30m"
    delete = "30m"
    update = "30m"
  }

  tags = {
    Name = local.cluster_nm
    Environment = var.env
  }
}

################################################################################
# IRSA - this is different from EKS identity provider
################################################################################
data "tls_certificate" "oidc" {
  url = aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "oidc" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.oidc.certificates[0].sha1_fingerprint]
  url = aws_eks_cluster.cluster.identity[0].oidc[0].issuer

  tags = {
    Name = format("%s-%s", local.cluster_nm, "irsa")
    Environment = var.env
  }
}

########################################################################
# CloudWatch 생성
########################################################################
resource "aws_cloudwatch_log_group" "cluster" {
  name = "/aws/eks/${local.cluster_nm}/cluster"
  retention_in_days = 7
  kms_key_id = var.kms_key_arn

  tags = {
    Name = format("%s-%s", local.cluster_nm, "log")
    Environments = var.env
  }
}