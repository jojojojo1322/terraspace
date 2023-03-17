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
# 생성된 vpc id
################################################################
variable "vpc_id" {
    type = string
}

###############################################################
# 생성한 클러스터 이름
###############################################################
variable "cluster_name" {
  type = string
}

###############################################################
# 생성된 보안그룹 ID
###############################################################
# 1. 클러스터 보안그룹 ID
variable "cluster_security_id" {
  type = string
}
# 2. Bastion Host 보안그룹 ID
variable "bastion_security_id" {
  type = string
}
# 3. Bastion Host Key Pair Name
variable "key_name" {
    type = string
}

###############################################################
# 노드를 생성하기 위한 대상 서브넷
###############################################################
variable "private_subnet_ids" {
    type = list(string)
}

###############################################################
# NODE 인스턴스 정보
###############################################################
# 1. 인스턴스 타입
variable "instance_type" {
    type = string
}
# 2. 최소 노드 개수
variable "min_size" {
    type = number
}
# 3. 최대 노드 개수
variable "max_size" {
    type = number
}

###############################################################
# PORT 정보 사전정의
###############################################################
variable "ports" {
  type = object(
  {
    ssh_port = number
    db_port = number
    http_port = number
    https_port = number
    node_from_port = number
    node_to_port = number
    any_port = number
    any_protocol = string
    tcp_protocol = string
    all_ips = list(string)
  })
}