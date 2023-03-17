#######################################################################
# 생성된 Cluster name
#######################################################################
variable "cluster_name" {
  type = string
}

########################################################################
# Karpenter 생성 여부
########################################################################
variable "create_role" {
  type = bool
}

########################################################################
# Karpenter - IAM Role
########################################################################
variable "role_name" {
  type = string
  default = null
}

########################################################################
# Karpenter controller 정책 병합
########################################################################
variable "attach_karpenter_controller_policy" {
  type = bool
  default = false
}

########################################################################
# Karpenter 대상 EKS Cluster ID
########################################################################
variable "karpenter_controller_cluster_id" {
  type = string
  default = "*"
}

########################################################################
# 클러스터 OIDC Provider
########################################################################
variable "oidc_providers" {
  type = any
  default = {}
}

########################################################################
# Karpenter 생성에 필요한 내부변수 설정
########################################################################
# Role Condition Test
variable "assume_role_condition_test" {
  type = string
  default = "StringEquals"
}

# Karpenter Tag Key name
variable "karpenter_tag_key" {
  type = string
  default = "karpenter.sh/discovery"
}

# Karpenter 서브넷 계정 ID :: 다른 계정과 서브넷을 공유할 때 지정
variable "karpenter_subnet_account_id" {
  type = string
  default = ""
}

# Karpenter SSM parameter arn
variable "karpenter_controller_ssm_parameter_arns" {
  type = list(string)
  default = ["arn:aws:ssm:*:*:parameter/aws/service/*"]
}

# Karpenter - Policy Name Prefix
variable "policy_name_prefix" {
  type = string
  default = "AmazonEKS_"
}
