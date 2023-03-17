########################################################################
# 생성된 EKS cluster 정보 조회
########################################################################
data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}
data "aws_eks_cluster_auth" "cluster" {
  name = var.cluster_name
}
data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  partition  = data.aws_partition.current.partition
  dns_suffix = data.aws_partition.current.dns_suffix
}

########################################################################
# Helm Provider 정의
########################################################################
provider "helm" {
  kubernetes {
    host = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    token = data.aws_eks_cluster_auth.cluster.token
  }
}

########################################################################
# Karpenter - Helm 설치
########################################################################
resource "helm_release" "karpenter" {
  count = var.create_role && var.attach_karpenter_controller_policy ? 1 : 0

  namespace = "karpenter"
  create_namespace = true

  name = "karpenter"
  repository = "https://charts.karpenter.sh"
  chart = "karpenter"
  version = "v0.13.2"

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.this[0].arn
  }

  set {
    name  = "clusterName"
    value = data.aws_eks_cluster.cluster.name
  }

  set {
    name  = "clusterEndpoint"
    value = data.aws_eks_cluster.cluster.endpoint
  }

  set {
    name  = "aws.defaultInstanceProfile"
    value = aws_iam_instance_profile.karpenter[0].name
  }
}


########################################################################
# Kubectl Provider 정의
########################################################################
# terraform required providers
terraform {
  required_version = "~> 1.0"

  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.14.0"
    }
  }
}

# kubectl provider
provider "kubectl" {
  apply_retry_count = 5
  host = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token = data.aws_eks_cluster_auth.cluster.token
  load_config_file = false
}

########################################################################
# Karpenter Provisioner
########################################################################
resource "kubectl_manifest" "karpenter_provisioner" {
  count = var.create_role && var.attach_karpenter_controller_policy ? 1 : 0
  
  yaml_body = <<-YAML
  apiVersion: karpenter.sh/v1alpha5
  kind: Provisioner
  metadata:
    name: default
  spec:
    requirements:
      - key: karpenter.sh/capacity-type
        operator: In
        values: ["spot"]
    limits:
      resources:
        cpu: 1000
    provider:
      subnetSelector:
        karpenter.sh/discovery: ${data.aws_eks_cluster.cluster.name}
      securityGroupSelector:
        karpenter.sh/discovery: ${data.aws_eks_cluster.cluster.name}
      tags:
        karpenter.sh/discovery: ${data.aws_eks_cluster.cluster.name}
    ttlSecondsAfterEmpty: 30
  YAML
}