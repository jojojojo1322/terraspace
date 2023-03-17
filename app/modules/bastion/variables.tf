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
# EC2 인스턴스 AMI 및 Instance Type
###############################################################
# ami 변수
variable "ami" {
  type = string
}

# instance type 변수
variable "instance_type" {
  type = string
}

###############################################################
# Defined Ports
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

###############################################################
# 생성된 vpc id
################################################################
variable "vpc_id" {
    type = string
}

###############################################################
# 생성된 public subnet id 목록
################################################################
variable "public_subnet_ids" {
    type = list(string)
}