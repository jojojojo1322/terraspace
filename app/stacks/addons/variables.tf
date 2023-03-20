###############################################################
# 프로젝트 서비스 이름
###############################################################
variable "svr_nm" {
  type = string
  default = "topas"
}

###############################################################
# AutoScaler 모드
###############################################################
variable "autoscaler_mode" {
  type = string
  default = "ca"
}

###############################################################
# Grafana Loki에 적용할 역할명
###############################################################
variable "loki_index" {
  type = string
  default = "loki_"
}

###############################################################
# BASE 스택에서 전달받은 변수 선언
###############################################################
# 1. 생성된 VPC ID
variable "vpc_id" {
  type = string
  default = null
}

###############################################################
# EKS 스택에서 전달받은 변수 선언
###############################################################
# 1. 생성된 Cluster name
variable "cluster_name" {
  type = string
  default = null
}
# 4. 생성된 Cluster oidc issur
variable "cluster_oidc_issuer" {
  type = string
  default = null
}
# 5. 생성된 Cluster oidc arn
variable "cluster_oidc_arn" {
  type = string
  default = null
}
# 8. 생성된 KMS KEY ARN
variable "kms_key_arn" {
  type = string
  default = null
}

###############################################################
# 생성할 클러스터 ADD-ON 상세
###############################################################
variable "addons" {
  type = list(object({
    name    = string
    version = string
  }))

  default = [
    {
      name    = "kube-proxy"
      version = "v1.22.6-eksbuild.1"
    },
    {
      name    = "vpc-cni"
      version = "v1.11.2-eksbuild.1"
    },
    {
      name    = "coredns"
      version = "v1.8.7-eksbuild.1"
    },
    {
      name    = "aws-ebs-csi-driver"
      version = "v1.8.0-eksbuild.0"
    }
  ]
}

###############################################################
# AWS Load Balancer Controller
###############################################################
# load balancer controller role name
variable "lb_controller_iam_role_name" {
  type = string
  default = "aws-load-balancer-controller"
}
# 
variable "lb_controller_service_account_name" {
  type = string
  default = "aws-load-balancer-controller"
}

###############################################################
# Grafana-Loki 버전 정보
# 버전 탐색 : helm search repo -l <name>
###############################################################
# 1. metric server version
variable "chart_version_metrics_server" {
  type = string
  default = "3.8.2"
}
# 2. prometheus version
variable "chart_version_prometheus" {
  type = string
  default = "15.10.5"
}
# 3. promtail version (2022.08.01 기준)
variable "chart_version_promtail" {
  type = string
  default = "6.2.2"
}
# 4. loki distributed version (2022.08.01 기준)
variable "chart_version_loki_distributed" {
  type = string
  default = "0.54.0"
}
# 5. grafana version (2022.08.01 기준)
variable "chart_version_grafana" {
  type = string
  default = "6.32.10"
}
