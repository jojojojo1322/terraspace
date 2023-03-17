###############################################################
# 프로젝트 환경 변수
###############################################################
variable "env" {
  type = string
  default = "<%= expansion(':ENV') %>"
}

###############################################################
# 프로젝트 서비스 이름
###############################################################
variable "svr_nm" {
  type = string
}

###############################################################
# 생성된 VPC ID
###############################################################
variable "vpc_id" {
  type = string
}

###############################################################
# 프로젝트 클러스터 이름
###############################################################
variable "cluster_name" {
  type = string
}

###############################################################
# AWS Load Balancer Controller 변수
###############################################################
# ALB Controller Create Flag
variable "create_role" {
  type = bool
}
# ALB Controller IAM Role Name
variable "role_name" {
  type = string
}
# ALB Controller IAM Role Path
variable "role_path" {
  type = string
}
# ALB Controller IAM Role Description
variable "role_description" {
  type = string
}
# EKS OIDC Provider URL
variable "provider_url" {
  type = string
}
# EKS OIDC Provider URL's
variable "provider_urls" {
  type = list(string)
}
# EKS Role Policy ARNs
variable "role_policy_arns" {
  type = list(string)
}
# EKS OIDC Provicer Qualified Subjects
variable "oidc_fully_qualified_subjects" {
  type = set(string)
}
# EKS OIDC Provicer Qualified Audiences
variable "oidc_fully_qualified_audiences" {
  type = set(string)
}

###############################################################
# AWS Load Balancer Controller 생성에 사용되는 기본값
###############################################################
# ALB Controller IAM Role Name Prefix
variable "role_name_prefix" {
  type = string
  default = null
}
# EKS OIDC Provicer WildCards
variable "oidc_subjects_with_wildcards" {
  type = set(string)
  default = []
}
# EKS IAM Role Max Session Duration :: 3600~43200
variable "max_session_duration" {
  type = number
  default = 3600
}
# IAM Role Force Detach Policy
variable "force_detach_policies" {
  type = bool
  default = false
}
# IAM Role Permissions Boundary ARN
variable "role_permissions_boundary_arn" {
  type = string
  default = ""
}