########################################################################
# 생성된 EKS cluster 정보 조회
########################################################################
data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}
data "aws_eks_cluster_auth" "cluster" {
  name = var.cluster_name
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
# AWS Load Balancer Controller 정책 다운로드
########################################################################
data "http" "iam_policy" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.4.1/docs/install/iam_policy.json"
}

########################################################################
# 다운로드받은 정책을 AWS IAM Role에 Attatch
########################################################################
resource "aws_iam_role_policy" "controller" {
  name_prefix = "AWSLoadBalancerControllerWithHelmIAMPolicy"
  policy = data.http.iam_policy.body
  role = aws_iam_role.this[0].name
}

########################################################################
# Amazon Load Balancer Controller - Helm 설치
########################################################################
resource "helm_release" "release" {
  name = "aws-load-balancer-controller"
  chart = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  namespace = "kube-system"

  dynamic "set" {
    for_each = {
      "clusterName" = data.aws_eks_cluster.cluster.name
      "serviceAccount.create" = "true"
      # role_name과 serviceaccount name을 동일하게 구성하였음 (aws-load-balancer-controller)
      "serviceAccount.name" = var.role_name
      "region" = "ap-northeast-2"
      "vpcId" = var.vpc_id
      "image.repository" = "602401143452.dkr.ecr.ap-northeast-2.amazonaws.com/amazon/aws-load-balancer-controller"
      "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn" = aws_iam_role.this[0].arn
    }
    content {
      name  = set.key
      value = set.value
    }
  }
}