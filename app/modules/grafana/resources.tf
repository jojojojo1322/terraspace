###########################################################################
# 클러스터 정보 조회
###########################################################################
data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}
data "aws_eks_cluster_auth" "cluster" {
  name = var.cluster_name
}

###########################################################################
# Local Variables
###########################################################################
locals {
  prom_svc = "prometheus-server.${var.k8s_namespace}.svc.cluster.local"
  loki_address = "http://loki-loki-distributed-gateway.${var.k8s_namespace}.svc.cluster.local/loki/api/v1/push"
  loki_svc = "loki-loki-distributed-querier.${var.k8s_namespace}.svc.cluster.local:3100"
}

########################################################################
# Helm Provider 정의
########################################################################
provider "helm" {
  kubernetes {
    host = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    token = data.aws_eks_cluster_auth.cluster.token
  }
}

###########################################################################
# Metric Server :: Helm 설정
###########################################################################
resource "helm_release" "metrics_server" {
  name = var.helm_release_name_metrics_server
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart = "metrics-server"
  namespace = var.k8s_namespace
  version = var.chart_version_metrics_server

  recreate_pods     = true                      # 업그레이드/롤백 중에 포드 다시 시작을 수행
  atomic            = true                      # 설정하면 설치 프로세스가 실패 시 차트를 제거
  cleanup_on_fail   = true                      # 업그레이드 실패 시 이 업그레이드에서 생성된 새 리소스 삭제를 허용
  wait              = true                      # 릴리스를 성공한 것으로 표시하기 전에 모든 리소스가 준비 상태가 될 때까지 대기
  wait_for_jobs     = true                      # 대기가 활성화된 경우 릴리스를 성공한 것으로 표시하기 전에 모든 작업이 완료될 때까지 대기
  timeout           = 300                       # 작업이 완료될 떄까지 기다리는 허용시간 (단위, 초)
  max_history       = 3                         # 릴리스당 저장된 릴리스 버전의 최대 수 (기본값 무제한, 0)
  verify            = false                     # 패키지를 설치하기 전에 유효성 확인
  keyring           = ".gnupg/pubring.gpg"      # 검증에 사용되는 공개 키의 위치
  reuse_values      = false                     # 업그레이드할 때 마지막 릴리스의 값을 재사용하고 재정의에서 병합
  reset_values      = false                     # 업그레이드 시 차트에 내장된 값으로 재설정
  force_update      = false                     # 필요한 경우 삭제/재생성을 통해 리소스 업데이트를 강제 실행
  replace           = false                     # 해당 이름이 기록에 남아 있는 삭제된 릴리스인 경우에만 지정된 이름을 다시 사용
  create_namespace  = true                      # 아직 존재하지 않는 경우 네임스페이스를 생성
  dependency_update = false                     # 차트를 설치하기 전에 helm 종속성 업데이트를 실행
  skip_crds         = false                     # CRD가 존재하지 않는 경우 설치

  values = [
    templatefile("${path.module}/templates/metrics-server.yml.tpl", {
      metrics_server_iam_role_arn = module.metrics.iam_role_arn
      metrics_server_k8s_sa_name = var.metrics_server_k8s_sa_name
    })
  ]
}

###########################################################################
# Prometheus Server :: Helm 설정
###########################################################################
resource "helm_release" "prometheus" {
  depends_on = [helm_release.metrics_server]

  name = var.helm_release_name_prometheus
  repository = "https://prometheus-community.github.io/helm-charts"
  chart = "prometheus"
  namespace = var.k8s_namespace
  version = var.chart_version_prometheus

  recreate_pods     = true
  atomic            = true
  cleanup_on_fail   = true
  wait              = true
  wait_for_jobs     = true
  timeout           = 300
  max_history       = 3
  verify            = false
  keyring           = ".gnupg/pubring.gpg"
  reuse_values      = false
  reset_values      = false
  force_update      = false
  replace           = false
  create_namespace  = true
  dependency_update = false
  skip_crds         = false

  values = [
    templatefile("${path.module}/templates/prometheus.yml.tpl", {
      prometheus_iam_role_arn = module.prometheus.iam_role_arn
      prometheus_k8s_sa_name = var.prometheus_k8s_sa_name
    })
  ]
}

###########################################################################
# Loki Distributed Server :: Helm 설정
###########################################################################
resource "helm_release" "loki_distributed" {
  count = var.loki_mode == "distributed" ? 1 : 0
  name = var.helm_release_name_loki
  repository = "https://grafana.github.io/helm-charts"
  chart = "loki-distributed"
  namespace = var.k8s_namespace
  version = var.chart_version_loki_distributed

  recreate_pods     = true
  atomic            = true
  cleanup_on_fail   = true
  wait              = true
  wait_for_jobs     = true
  timeout           = 200
  max_history       = 3
  verify            = false
  keyring           = ".gnupg/pubring.gpg"
  reuse_values      = false
  reset_values      = false
  force_update      = false
  replace           = false
  create_namespace  = true
  dependency_update = false
  skip_crds         = false

  values = [
    templatefile("${path.module}/templates/loki-distributed.yml.tpl", {
      aws_region = data.aws_region.current.name
      bucket_name = aws_s3_bucket.this.bucket
      loki_iam_role_arn = module.loki.iam_role_arn
      loki_k8s_sa_name = var.loki_k8s_sa_name
      loki_index = var.loki_index
    })
  ]
}

###########################################################################
# Promtail Server :: Helm 설정
###########################################################################
resource "helm_release" "promtail" {
  depends_on = [helm_release.loki_distributed]

  count = var.loki_aggregator == "promtail" ? 1 : 0
  name = var.helm_release_name_promtail
  repository = "https://grafana.github.io/helm-charts"
  chart = "promtail"
  namespace = var.k8s_namespace
  version = var.chart_version_promtail

  recreate_pods     = true
  atomic            = true
  cleanup_on_fail   = true
  wait              = true
  wait_for_jobs     = true
  timeout           = 300
  max_history       = 3
  verify            = false
  keyring           = ".gnupg/pubring.gpg"
  reuse_values      = false
  reset_values      = false
  force_update      = false
  replace           = false
  create_namespace  = true
  dependency_update = false
  skip_crds         = false

  values = [
    templatefile("${path.module}/templates/promtail.yml.tpl", {
      loki_iam_role_arn = module.loki.iam_role_arn
      loki_address = local.loki_address
    })
  ]
}

###########################################################################
# Grafana Server :: Helm 설정
###########################################################################
resource "helm_release" "grafana" {
  depends_on = [
    helm_release.promtail,
    helm_release.prometheus
  ]

  name = var.helm_release_name_grafana
  repository = "https://grafana.github.io/helm-charts"
  chart = "grafana"
  namespace = var.k8s_namespace
  version = var.chart_version_grafana

  recreate_pods     = true
  atomic            = true
  cleanup_on_fail   = true
  wait              = true
  wait_for_jobs     = true
  timeout           = 300
  max_history       = 3
  verify            = false
  keyring           = ".gnupg/pubring.gpg"
  reuse_values      = false
  reset_values      = false
  force_update      = false
  replace           = false
  create_namespace  = true
  dependency_update = false
  skip_crds         = false

  values = [
    templatefile("${path.module}/templates/grafana.yml.tpl", {
      aws_region = data.aws_region.current.name
      prom_svc = local.prom_svc
      loki_svc = local.loki_svc
      grafana_k8s_sa_name = var.grafana_k8s_sa_name
      grafana_iam_role_arn = module.grafana.iam_role_arn
    })
  ]
}
