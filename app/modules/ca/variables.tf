###############################################################
# Cluster Autoscaler 변수
###############################################################
# cluster autoscaler role 이름
variable "ca_iam_role_name" {
  type = string
  default = "cluster-autoscaler"
}
# cluster autoscaler service asscount 이름
variable "ca_k8s_sa_name" {
  type = string
  default = "cluster-autoscaler"
}
# cluster autoscaler 생성여부
variable "create_role" {
  type = bool
  default = false
}

###############################################################
# EKS 스택에서 전달받은 변수 선언
###############################################################
# 1. 생성된 Cluster Name
variable "cluster_name" {
  type = string
  default = null
}
# 2. 생성된 Cluster oidc arn
variable "cluster_oidc_arn" {
  type = string
  default = null
}