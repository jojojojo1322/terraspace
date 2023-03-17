###################################################################################
# EKS Cluster Output
###################################################################################
# Cluster name
output "cluster_name" {
  value = module.cluster.cluster_name
}

# EKS cluster endpoint
output "endpoint" {
  value = module.cluster.endpoint
}

# EKS cluster에 대한 속성 block 값
output "kubeconfig-certificate-authority-data" {
  value = module.cluster.kubeconfig-certificate-authority-data
}

# EKS cluster issuer
output "cluster_oidc_issuer" {
  value = module.cluster.cluster_oidc_issuer
}

###################################################################################
# OIDC arn
###################################################################################
output "oidc_arn" {
  value = module.cluster.oidc_arn
}
