################################################################################
# Fargate 만으로 클러스터가 운영되면 CoreDNS 패치를 수행하여야 한다.
# 조건은 enable_nodegroup 값이 false인 경우에 적용한다.
# 패치를 적용하지 않으려면, 클러스터 구성이 완료된 마지막에 ADD ON을 수행한다.
# -------------------------------------------------------------------------------
# $ aws eks update-kubeconfig --region ap-northeast-2 --name topas-dev
# $ kubectl patch deployment coredns -n kube-system --type json \
#   -p='[{"op": "remove", "path": "/spec/template/metadata/annotations/eks.amazonaws.com~1compute-type"}]'
################################################################################

################################################################################
# EKS Addons
################################################################################
resource "aws_eks_addon" "addons" {
  for_each = { for addon in var.addons : addon.name => addon }
  cluster_name = var.cluster_name
  addon_name = each.value.name
  addon_version = each.value.version
  resolve_conflicts = "OVERWRITE"

  tags = {
    Name = format("%s-%s", var.cluster_name, "addon")
    Environment = var.env
  }
}
