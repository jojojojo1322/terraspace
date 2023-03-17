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
  default = "topas-tf-eks"
}

###############################################################
# 생성할 클러스터 버전
###############################################################
variable "cluster_version" {
  type = string
  default = "1.22"
}

###############################################################
# 클러스터 마스터 노드에 접근하기 위한 CIDR Block (workstation)
###############################################################
variable "workstation_cidr" {
  type = list(string)
  default = ["211.206.114.80/32"]
}

###############################################################
# Base 스택에서 전달받은 변수 선언
###############################################################
# 1. VPC ID
variable "vpc_id" {
  type = string
  default = null
}

# 2. 생성된 public subnet ids
variable "public_subnet_ids" {
  type = list(string)
  default = null
}

# 3. 생성된 private subnet ids
variable "private_subnet_ids" {
  type = list(string)
  default = null
}

# 4. 생성된 rds(private) subnet ids
variable "rds_subnet_ids" {
  type = list(string)
  default = null
}

# 5. 생성된 KMS KEY ARN
variable "kms_key_arn" {
  type = string
  default = null
}

# 6. 생성된 Bastion Host Key Pair name
variable "key_name" {
  type = string
  default = null
}

# 7. 생성된 Bastion Host Security Group ID
variable "bastion_security_id" {
  type = string
  default = null
}

###############################################################
# NodeGroup 및 Fargate 생성여부 설정 :
# 주의) nodegroup 및 fargate 둘중 하나는 true여야 한다.
###############################################################
variable "enable_nodegroup" {
  type = bool
  default = true
}

variable "enable_fargate" {
  type = bool
  default = false
}

###############################################################
# Instance variables
###############################################################
variable "ami" {
  type = map(string)
  default = {
    "instance" = "ami-0263588f2531a56bd",
    "bastion" = "ami-0263588f2531a56bd"
  }
}

variable "instance_type" {
  type = map(string)
  default = {
    "instance"= "t3.medium",
    "bastion"="t3.medium",
    "database" = "db.t2.micro"
  }
}

# node min size
variable "min_size" {
    type = number
    default = 1
}

# node max size
variable "max_size" {
    type = number
    default = 3
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

  default = {
    ssh_port = 22
    db_port = 5432
    http_port = 80
    https_port = 443
    node_from_port = 1025
    node_to_port = 65535
    any_port = 0
    any_protocol = "-1"
    tcp_protocol = "tcp"
    all_ips = ["0.0.0.0/0"]
  }
}
