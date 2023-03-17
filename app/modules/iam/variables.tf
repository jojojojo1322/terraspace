###############################################################
# role 생성 여부
###############################################################
variable "create_role" {
  type = bool
  default = true
}

########################################################################
# 클러스터 OIDC Provider
########################################################################
variable "oidc_providers" {
  type = any
  default = {}
}

########################################################################
# Role Condition Test
########################################################################
variable "assume_role_condition_test" {
  type = string
  default = "StringEquals"
}

########################################################################
# IAM Role 이름
########################################################################
variable "role_name" {
  type = string
  default = null
}