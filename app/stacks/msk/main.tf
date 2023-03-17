###################################################################################
# Amazon MSK cluster 생성
###################################################################################
module "msk" {
  source = "../../modules/msk"

  # 서비스 이름
  svr_nm = var.svr_nm
  # 클러스터 생성 여부
  create = var.create
  # 클러스터 버전
  kafka_version = var.kafka_version
  # 클라우드워치 모니터링 수준
  enhanced_monitoring = var.enhanced_monitoring
  # EBS Volume Size
  ebs_volume_size = var.ebs_volume_size
  # Kafka Instance Type
  instance_type = var.instance_type
  # 보안그룹 rule
  rules = var.rules
  ingress_rules = ["kafka-broker-tcp", "kafka-broker-tls-tcp", "kafka-broker-sasl-scram-tcp", "kafka-broker-sasl-iam-tcp", 
                   "kafka-jmx-exporter-tcp", "kafka-node-exporter-tcp","zookeeper-2181-tcp"]
  cidr_block = var.cidr_block
  # (클라이언트) 보안설정
  client_authentication_tls_certificate_authority_arns = var.client_authentication_tls_certificate_authority_arns
  client_authentication_unauthenticated_enabled = true  # 인증되지 않은 엑세스
  client_authentication_sasl_iam_enabled  = true        # IAM 역할 기반 인증

  # MSK Configuration Properteis
  server_properties = {
    "auto.create.topics.enable"  = "true"
    "default.replication.factor" = "2"
  }
  # 브로커 노드간에 데이터 통신이 암호화되는지 여부
  encryption_in_transit_in_cluster = true
  # 클라이언트와 브로커간에 전송중인 데이터에 대한 암호화 설정
  # TLS, TLS_PLAINTEXT (default: TLS_PLAINTEXT)
  encryption_in_transit_client_broker = "TLS"

  # 프로메테우스 오픈 모니터링
  prometheus_jmx_exporter  = true
  prometheus_node_exporter = true

  # 클라우드워치 로그그룹 이름
  cloudwatch_logs_group = "/aws/mks/${var.svr_nm}/${var.env}"

  # VPC ID
  vpc_id = var.vpc_id
  # subnet ids
  kafka_subnet_ids = var.kafka_subnet_ids
  # kms key arn
  kms_key_arn = var.kms_key_arn
  # bastion host 보안그룹 ID
  bastion_security_id = var.bastion_security_id
}