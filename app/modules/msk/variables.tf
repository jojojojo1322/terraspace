###############################################################
# 프로젝트 환경 변수
###############################################################
variable "env" {
  type = string
  default = "<%= expansion(':ENV') %>"
}

# 클러스터 생성 여부
variable "create" {
  type = bool
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
  type = list(string)
}

###############################################################
# PORT 정보 사전정의
###############################################################
variable "ports" {
  type = object(
  {
    any_port = number
    any_protocol = string
    tcp_protocol = string
    all_ips = list(string)
  })

  default = {
    any_port = 0
    any_protocol = "-1"
    tcp_protocol = "tcp"
    all_ips = ["0.0.0.0/0"]
  }
}

###############################################################
# Base 스택에서 전달받은 변수 선언
###############################################################
# 1. VPC ID
variable "vpc_id" {
  type = string
  default = null
}

# 2. 생성된 kafka subnet ids
variable "kafka_subnet_ids" {
  type = list(string)
  default = null
}

# 3. 생성된 KMS KEY ARN
variable "kms_key_arn" {
  type = string
  default = null
}

# 4. 생성된 Bastion Host Security Group ID
variable "bastion_security_id" {
  type = string
  default = null
}

###############################################################
# Kafka 관련 변수
###############################################################
# Kafka 버전
variable "kafka_version" {
  type = string
}

# 클라우드워치 모니터링 수준
variable "enhanced_monitoring" {
  type = string
}

# EBS Volume Size
variable "ebs_volume_size" {
  type = number
}

# kafka instance type
variable "instance_type" {
  type = string
}

# kafka 보안그룹 사전정의 rule
variable "rules" {
  type = map(list(any))
}

# kafka 보안그룹 rule
variable "ingress_rules" {
  type = list(string)
}

# MSK Configuration Properteis
variable "server_properties" {
  type = map(string)
  default = {}
}

# 클라이언트와 브로커간에 전송중인 데이터에 대한 암호화 설정
# TLS, TLS_PLAINTEXT (default: TLS_PLAINTEXT)
variable "encryption_in_transit_client_broker" {
  type = string
  default = "TLS_PLAINTEXT"
}

# 브로커 노드간에 데이터 통신이 암호화되는지 여부
variable "encryption_in_transit_in_cluster" {
  type = bool
}

###############################################################
# Kafka 인증 설정
###############################################################
# 인증되지 않은 엑세스
variable "client_authentication_unauthenticated_enabled" {
  type = bool
}

# IAM 역할 기반 인증
variable "client_authentication_sasl_iam_enabled" {
  type = bool
}

# ACM(AWS Certificate Manager)을 통한 TLS 클라이언트 인증
variable "client_authentication_tls_certificate_authority_arns" {
  type = list(string)
}

###############################################################
# Kafka 오픈 모니터링
###############################################################
variable "prometheus_jmx_exporter" {
  type = bool
  default = false
}
variable "prometheus_node_exporter" {
  type = bool
  default = false
}

###############################################################
# Kafka 브로커 로그 전송
###############################################################
# Kinesis Data Firehose 스트림 이름
variable "firehose_logs_delivery_stream" {
  type = string
  default = ""
}

# S3 버킷 이름
variable "s3_logs_bucket" {
  type = string
  default = ""
}

# S3 Bucket 경로 이름
variable "s3_logs_prefix" {
  type = string
  default = ""
}

# 클라우드 워치 그룹 이름
variable "cloudwatch_logs_group" {
  type = string
  default = ""
}