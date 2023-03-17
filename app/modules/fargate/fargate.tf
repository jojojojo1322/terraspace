###############################################################
# Local Variables
###############################################################
locals {
  cluster_nm = format("%s-%s", var.svr_nm, var.env)
}

########################################################################
# Fargate profile 등록
########################################################################
resource "aws_eks_fargate_profile" "frontend" {
  cluster_name = local.cluster_nm
  fargate_profile_name = format("%s-%s", local.cluster_nm, "frontend")
  pod_execution_role_arn = aws_iam_role.fargate.arn
  subnet_ids = var.private_subnet_ids

  selector {
    namespace = "default"
    labels = {
      app = "frontend"
    }
  }

  timeouts {
    create = "30m"
    delete = "30m"
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.fargate
  ]
}