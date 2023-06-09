###################################################################################
# EKS Cluster Output
###################################################################################
# Cluster name
output "cluster_name" {
  value = aws_eks_cluster.cluster.name
}

# EKS cluster endpoint
output "endpoint" {
  value = aws_eks_cluster.cluster.endpoint
}

# EKS cluster에 대한 속성 block 값
output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.cluster.certificate_authority[0].data
}

# EKS cluster issuer
output "cluster_oidc_issuer" {
  value = aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

###################################################################################
# OIDC arn
###################################################################################
output "oidc_arn" {
  value = aws_iam_openid_connect_provider.oidc.arn
}

###################################################################################
# EKS cluster security group ID
###################################################################################
output "cluster_security_id" {
  value = aws_security_group.cluster.id
}