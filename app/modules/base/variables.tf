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
# VPC에 적용하기 위한 CIDR BLOCK
###############################################################
variable "cidr_block" {
  type = string
}

###############################################################
# 서브넷에 적용하기 위한 CIDR BLOCK
###############################################################
variable "subnets" {
  type = object(
  {
    public = map(string)
    private = map(string)
    rds = map(string)
  })
}

###############################################################
# RDS에 적용할 서브넷 생성 여부
###############################################################
variable "enable_rds_subnet" {
  type = bool
}
