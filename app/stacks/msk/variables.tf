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
  default = true
}

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
  type = list(string)
  default = ["192.168.0.0/16"]
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
# Kafka 버전 (현재 권장 버전 = 2.6.2)
variable "kafka_version" {
  type = string
  default = "2.6.2"
}

# 클라우드워치 모니터링 수준
# value :: DEFAULT, PER_BROKER, PER_TOPIC_PER_BROKER, PER_TOPIC_PER_PARTITION
variable "enhanced_monitoring" {
  type = string
  default = "PER_BROKER"
}

# EBS Volume Size
variable "ebs_volume_size" {
  type = number
  default = 30
}

# kafka instance type
variable "instance_type" {
  type = string
  default = "kafka.t3.small"
}

# kafka 보안그룹 rule
variable "rules" {
  type = map(list(any))

  # Protocols (tcp, udp, icmp, all - are allowed keywords) or numbers
  # All = -1, IPV4-ICMP = 1, TCP = 6, UDP = 17, IPV6-ICMP = 58
  default = {
    # Kafka
    kafka-broker-tcp                    = [9092, 9092, "tcp", "Kafka PLAINTEXT enable broker 0.8.2+"]
    kafka-broker-tls-tcp                = [9094, 9094, "tcp", "Kafka TLS enabled broker 0.8.2+"]
    kafka-broker-tls-public-tcp         = [9194, 9194, "tcp", "Kafka TLS Public enabled broker 0.8.2+ (MSK specific)"]
    kafka-broker-sasl-scram-tcp         = [9096, 9096, "tcp", "Kafka SASL/SCRAM enabled broker (MSK specific)"]
    kafka-broker-sasl-scram-public-tcp  = [9196, 9196, "tcp", "Kafka SASL/SCRAM Public enabled broker (MSK specific)"]
    kafka-broker-sasl-iam-tcp           = [9098, 9098, "tcp", "Kafka SASL/IAM access control enabled (MSK specific)"]
    kafka-broker-sasl-iam-public-tcp    = [9198, 9198, "tcp", "Kafka SASL/IAM Public access control enabled (MSK specific)"]
    kafka-jmx-exporter-tcp              = [11001, 11001, "tcp", "Kafka JMX Exporter"]
    kafka-node-exporter-tcp             = [11002, 11002, "tcp", "Kafka Node Exporter"]
    # Zookeeper
    zookeeper-2181-tcp                  = [2181, 2181, "tcp", "Zookeeper"]
    zookeeper-2182-tls-tcp              = [2182, 2182, "tcp", "Zookeeper TLS (MSK specific)"]
    zookeeper-2888-tcp                  = [2888, 2888, "tcp", "Zookeeper"]
    zookeeper-3888-tcp                  = [3888, 3888, "tcp", "Zookeeper"]
    zookeeper-jmx-tcp                   = [7199, 7199, "tcp", "JMX"]
  }
}

# ACM(AWS Certificate Manager)을 통한 TLS 클라이언트 인증
variable "client_authentication_tls_certificate_authority_arns" {
  type = list(string)
  default = []
}
