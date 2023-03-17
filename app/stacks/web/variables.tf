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
  default = "topas"
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
variable "rules" {
  type = map(list(any))

  default = {
    # HTTP
    http-80-tcp   = [80, 80, "tcp", "HTTP"]
    http-8080-tcp = [8080, 8080, "tcp", "HTTP"]
    # HTTPS
    https-443-tcp  = [443, 443, "tcp", "HTTPS"]
    https-8443-tcp = [8443, 8443, "tcp", "HTTPS"]
    # MongoDB
    mongodb-27017-tcp = [27017, 27017, "tcp", "MongoDB"]
    mongodb-27018-tcp = [27018, 27018, "tcp", "MongoDB shard"]
    mongodb-27019-tcp = [27019, 27019, "tcp", "MongoDB config server"]
    # MySQL
    mysql-tcp = [3306, 3306, "tcp", "MySQL/Aurora"]
    # MSSQL Server
    mssql-tcp           = [1433, 1433, "tcp", "MSSQL Server"]
    mssql-udp           = [1434, 1434, "udp", "MSSQL Browser"]
    mssql-analytics-tcp = [2383, 2383, "tcp", "MSSQL Analytics"]
    mssql-broker-tcp    = [4022, 4022, "tcp", "MSSQL Broker"]
    # PostgreSQL
    postgresql-tcp = [5432, 5432, "tcp", "PostgreSQL"]
    # Redis
    redis-tcp = [6379, 6379, "tcp", "Redis"]
    # Redshift
    redshift-tcp = [5439, 5439, "tcp", "Redshift"]
    # SMTP
    smtp-tcp                 = [25, 25, "tcp", "SMTP"]
    smtp-submission-587-tcp  = [587, 587, "tcp", "SMTP Submission"]
    smtp-submission-2587-tcp = [2587, 2587, "tcp", "SMTP Submission"]
    smtps-465-tcp            = [465, 465, "tcp", "SMTPS"]
    smtps-2456-tcp           = [2465, 2465, "tcp", "SMTPS"]
    # SSH
    ssh-tcp = [22, 22, "tcp", "SSH"]
    # Web
    web-jmx-tcp = [1099, 1099, "tcp", "JMX"]
    # Open all ports & protocols
    all-all       = [-1, -1, "-1", "All protocols"]
    all-tcp       = [0, 65535, "tcp", "All TCP ports"]
    all-udp       = [0, 65535, "udp", "All UDP ports"]
    all-icmp      = [-1, -1, "icmp", "All IPV4 ICMP"]
    all-ipv6-icmp = [-1, -1, 58, "All IPV6 ICMP"]
  }
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

  default = {
    http_port = 80
    was_port = 8080
    any_port = 0
    any_protocol = "-1"
    tcp_protocol = "tcp"
    all_ips = ["0.0.0.0/0"]
  }
}

###############################################################
# EC2 정보 :: Web & WAS Server
###############################################################
# Web EC2 Instance Type
variable "web_instance_type" {
    type = string
    default = "t3.medium"
}

# WAS EC2 Instance Type
variable "was_instance_type" {
    type = string
    default = "t3.medium"
}

# Auto Scaling Group :: minimum size
variable "min_size" {
    type = number
    default = 2
}

# Auto Scaling Group :: maximum size
variable "max_size" {
    type = number
    default = 4
}

# Auto Scaling Schedule 동작 여부 설정 (true: 수행, false: 미수행)
variable "enable_autoscaling" {
    type = bool
    default = false
}

###############################################################
# VPC에 적용하기 위한 CIDR BLOCK
###############################################################
variable "cidr_block" {
  type = string
  default = "192.168.0.0/16"
}

###############################################################
# RDS 변수
###############################################################
# postgresql version
variable "postgres_version" {
  type = string
  default = "13.7"
}

# postgresql db instance
variable "instances" {
  type = object(
  {
    class_name = map(string)
  })

  default = {
    class_name = {
      "instance-writer" = "db.r6.large"
      "instance-reader" = "db.r6.2xlarge"
    }
  }
}

# rds 설치 az
variable "availability_zones" {
  type = list(string)
  default = ["ap-northeast-2a", "ap-northeast-2b"]
}

# postgresql port
variable "port" {
  type = number
  default = 5432
}

# RDS 계정
variable "master_username" {
  type = string
  default = "postgres"
}

# RDS 비밀번호
variable "master_password" {
  type = string
  default = "adminpass"
}

# Backup Retention Period
variable "backup_retention_period" {
  type = number
  default = 7
}
# 백업이 발생되는 일일 시간 범위
variable "preferred_backup_window" {
  type = string
  default = "07:00-09:00"
}