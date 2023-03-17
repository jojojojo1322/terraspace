###############################################################
# 프로젝트 서비스 이름
###############################################################
variable "svr_nm" {
  type = string
  default = "topas"
}

###############################################################
# VPC에 적용하기 위한 CIDR BLOCK
###############################################################
variable "cidr_block" {
  type = string
  default = "192.168.0.0/16"
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

  default = {
    public = {
    "192.168.1.0/24" = "ap-northeast-2a"
    "192.168.2.0/24" = "ap-northeast-2b"
    }
    private = {
    "192.168.51.0/24" = "ap-northeast-2a"
    "192.168.52.0/24" = "ap-northeast-2b"
    }
    rds = {
    "192.168.151.0/24" = "ap-northeast-2a"
    "192.168.152.0/24" = "ap-northeast-2b"
    }
  }
}

# RDS 서브넷에 적용하기 위한 CIDR BLOCK
variable "enable_rds_subnet" {
  type = bool
  default = true
}


###############################################################
# EC2 인스턴스 AMI 및 Instance Type
###############################################################
variable "ami" {
  type = map(string)
  default = {
    "instance"="ami-0263588f2531a56bd",
    "bastion"="ami-0263588f2531a56bd"
  }
}

# zone에 유효한 인스턴스 타입 여부 확인
# aws ec2 describe-instance-type-offerings --location-type availability-zone  --filters Name=instance-type,Values=t3.small --region ap-northeast-2 --output table
variable "instance_type" {
  type = map(string)
  default = {
    "instance"= "t3.medium",
    "bastion"="t3.medium",
    "database"="db.t2.medium	"
  }
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