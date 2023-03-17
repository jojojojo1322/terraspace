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
# Grafana Loki에 적용할 역할명
###############################################################
variable "loki_index" {
  type = string
  default = "loki_"
}

###############################################################
# EKS 스택에서 전달받은 변수 선언
###############################################################
# 1. 생성된 Cluster Name
variable "cluster_name" {
  type = string
  default = null
}
# 2. 생성된 KMS KEY ARN
variable "kms_key_arn" {
  type = string
  default = null
}
# 3. 생성된 KMS KEY ARN
variable "cluster_oidc_provider" {
  type = string
  default = null
}
# 4. 생성된 Cluster oidc arn
variable "cluster_oidc_arn" {
  type = string
  default = null
}

###############################################################
# Loki S3 Storage bucket 종료시 삭제 옵션
###############################################################
variable "s3_force_destroy" {
  type = bool
  default = true
}
# S3 expiration day
variable "expiration_days" {
  type = number
  default = 365
}

###############################################################
# Grafana-Loki 네임스페이스 지정
###############################################################
variable "k8s_namespace" {
  type = string
  default = "monitoring"
}

###############################################################
# Loki-Distributed 변수
###############################################################
# loki mode :: single or distributed
variable "loki_mode" {
  type = string
  default = "distributed"
}
# loki aggregator :: promtail or fluent-bit
variable "loki_aggregator" {
  type = string
  default = "promtail"
}
# loki IAM role 이름
variable "loki_iam_role_name" {
  type = string
  default = "loki"
}
# loki service account 이름
variable "loki_k8s_sa_name" {
  type = string
  default = "loki"
}
# helm 설치 loki distributed 이름
variable "helm_release_name_loki" {
  type = string
  default = "loki"
}
# grafana IAM role 이름
variable "grafana_iam_role_name" {
  type = string
  default = "grafana"
}
# grafana service account 이름
variable "grafana_k8s_sa_name" {
  type = string
  default = "grafana"
}
# helm 설치 grafana 이름
variable "helm_release_name_grafana" {
  type = string
  default = "grafana"
}
# Metrics Server IAM role 이름
variable "metrics_server_iam_role_name" {
  type = string
  default = "metrics-server"
}
# Metrics Server service account 이름
variable "metrics_server_k8s_sa_name" {
  type = string
  default = "metrics-server"
}
# helm 설치 Metrics Server 이름
variable "helm_release_name_metrics_server" {
  type = string
  default = "metrics-server"
}
# prometheus IAM role 이름
variable "prometheus_iam_role_name" {
  type = string
  default = "prometheusr"
}
# Metrics Server service account 이름
variable "prometheus_k8s_sa_name" {
  type = string
  default = "prometheus"
}
# helm 설치 Metrics Server 이름
variable "helm_release_name_prometheus" {
  type = string
  default = "prometheus"
}

###############################################################
# Promtail 변수
###############################################################
# helm 설치 promtail 이름
variable "helm_release_name_promtail" {
  type = string
  default = "promtail"
}

###############################################################
# Grafana-Loki 버전 정보
###############################################################
# loki distributed version
variable "chart_version_loki_distributed" {
  type = string
  default = null
}
# promtail version
variable "chart_version_promtail" {
  type = string
  default = null
}
# grafana version
variable "chart_version_grafana" {
  type = string
  default = null
}
# metric server version
variable "chart_version_metrics_server" {
  type = string
  default = null
}
# prometheus version
variable "chart_version_prometheus" {
  type = string
  default = null
}