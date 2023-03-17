###############################################################
# 프로젝트 환경 변수
###############################################################
variable "env" {
  type = string
  default = "<%= expansion(':ENV') %>"
}

variable "region" {
  type = string
  default = "<%= expansion(':REGION') %>"
}

###############################################################
# 프로젝트 서비스 이름
###############################################################
variable "svr_nm" {
  type = string
}

variable "create" {
  type = bool
  default = true
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

# 4. 생성된 expand subnet ids
variable "expand_subnet_ids" {
  type = list(string)
  default = null
}

# 5. 생성된 rds(private) subnet ids
variable "rds_subnet_ids" {
  type = list(string)
  default = null
}

# 6. 생성된 KMS KEY ARN
variable "kms_key_arn" {
  type = string
  default = null
}

# 7. 생성된 Bastion Host Key Pair name
variable "key_name" {
  type = string
  default = null
}

# 8. 생성된 Bastion Host Security Group ID
variable "bastion_security_id" {
  type = string
  default = null
}

###############################################################
# 보안그룹 생성 Rule
###############################################################
# 보안그룹 사전정의 rule
variable "rules" {
  type = map(list(any))
}

# Web Server 보안그룹 rule
variable "web_ingress_rules" {
  type = list(string)
}

# WAS Server 보안그룹 rule
variable "was_ingress_rules" {
  type = list(string)
}

# RDS Server 보안그룹 rule
variable "rds_ingress_rules" {
  type = list(string)
}

# all ips
variable "cidr_blocks" {
  type = list(string)
}

###############################################################
# PORT 정보 사전정의
###############################################################
variable "ports" {
  type = object(
  {
    http_port = number
    was_port = number
    any_port = number
    any_protocol = string
    tcp_protocol = string
    all_ips = list(string)
  })
}

###############################################################
# EC2 정보 :: Web & WAS Server
###############################################################
# Web EC2 Instance Type
variable "web_instance_type" {
    type = string
}

# WAS EC2 Instance Type
variable "was_instance_type" {
    type = string
}

# Auto Scaling Group :: minimum size
variable "min_size" {
    type = number
}

# Auto Scaling Group :: maximum size
variable "max_size" {
    type = number
}

# Auto Scaling Schedule 동작 여부 설정 (true: 수행, false: 미수행)
variable "enable_autoscaling" {
    type = bool
}

###############################################################
# VPC에 적용하기 위한 CIDR BLOCK
###############################################################
variable "cidr_block" {
  type = string
}

###############################################################
# RDS 변수
###############################################################
# postgresql version
variable "postgres_version" {
  type = string
}

# postgresql db instance
variable "instances" {
  type = object(
  {
    class_name = map(string)
  })
}
# rds 설치 az
variable "availability_zones" {
  type = list(string)
}
# postgresql port
variable "port" {
  type = number
}

# RDS 계정
variable "master_username" {
  type = string
}

# RDS 비밀번호
variable "master_password" {
  type = string
}

# Backup Retention Period
variable "backup_retention_period" {
  type = number
}
# 백업이 발생되는 일일 시간 범위
variable "preferred_backup_window" {
  type = string
}